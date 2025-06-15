from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import boto3
import os
from dotenv import load_dotenv
import tempfile
import json

# Load environment variables
load_dotenv()

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize AWS Textract client
textract_client = boto3.client(
    'textract',
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
    region_name=os.getenv('AWS_REGION', 'us-east-1')
)

# Initialize Bedrock client if not present
bedrock_client = boto3.client(
    'bedrock-runtime',
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
    region_name=os.getenv('AWS_REGION', 'us-east-1')
)

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    try:
        # Create a temporary file to store the upload
        with tempfile.NamedTemporaryFile(delete=False) as temp_file:
            content = await file.read()
            temp_file.write(content)
            temp_file.flush()
            
            # Read the file for Textract
            with open(temp_file.name, 'rb') as document:
                image_bytes = document.read()
            
            # Call Textract
            response = textract_client.detect_document_text(
                Document={'Bytes': image_bytes}
            )
            
            # Extract text from response
            extracted_text = ' '.join([item['Text'] for item in response['Blocks'] if item['BlockType'] == 'LINE'])
            
            # Clean up temporary file
            os.unlink(temp_file.name)
            
            return {
                "message": "File processed successfully",
                "extracted_text": extracted_text
            }
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/simplify")
async def simplify_text(request: dict):
    try:
        text = request.get("text", "")
        prompt = f"""Please simplify the following text for a student with learning challenges. 
Make it more accessible and easier to understand while maintaining the key information.
Provide three formats:
1. A simplified paragraph version
2. Key bullet points
3. Step-by-step explanation

Text to simplify:
{text}

Please format your response as a JSON object with these keys:
- simplified_text: The simplified paragraph version
- bullet_points: Array of key points
- step_by_step: Array of steps for understanding
"""
        response = bedrock_client.invoke_model(
            modelId='meta.llama3-8b-instruct-v1:0',
            body=json.dumps({
                "prompt": prompt,
                "max_gen_len": 1000,
                "temperature": 0.7
            })
        )
        response_body = json.loads(response['body'].read())
        # Llama returns the generated text in 'generation' or similar key
        # Try to parse the output as JSON (as instructed in the prompt)
        try:
            simplified_content = json.loads(response_body['generation'])
        except Exception:
            # If not valid JSON, just return the raw output
            simplified_content = {
                "simplified_text": response_body.get('generation', ''),
                "bullet_points": [],
                "step_by_step": []
            }
        return simplified_content
    except Exception as e:
        return {"error": str(e)}

@app.get("/")
async def root():
    return {"message": "Welcome to AI Nable Backend"} 