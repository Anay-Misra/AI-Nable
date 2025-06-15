from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import boto3
import os
from dotenv import load_dotenv
import tempfile
from typing import Optional, List
import logging
import json

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
import json

# Load environment variables
load_dotenv()

# Debug: Print environment variables (without secret)
logger.info(f"AWS Access Key ID: {os.getenv('AWS_ACCESS_KEY_ID')[:5]}...")
logger.info(f"AWS Region: {os.getenv('AWS_REGION')}")

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Constants
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB
ALLOWED_EXTENSIONS = {'.pdf', '.jpg', '.jpeg', '.png'}

# Response Models
class TextExtractionResponse(BaseModel):
    message: str
    extracted_text: str
    file_name: str
    file_type: str

class TextSimplificationResponse(BaseModel):
    simplified_text: str
    bullet_points: List[str]
    step_by_step: List[str]

class NarrationResponse(BaseModel):
    audio_url: str
    duration: float

class ErrorResponse(BaseModel):
    detail: str

class TextSimplificationRequest(BaseModel):
    text: str

class NarrationRequest(BaseModel):
    text: str

# Initialize AWS clients
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

bedrock_client = boto3.client(
    'bedrock-runtime',
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
    region_name=os.getenv('AWS_REGION', 'us-east-1')
)

polly_client = boto3.client(
    'polly',
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
    region_name=os.getenv('AWS_REGION', 'us-east-1')
)

def validate_file(file: UploadFile) -> None:
    """Validate file size and type"""
    # Check file size
    file_size = 0
    for chunk in file.file:
        file_size += len(chunk)
        if file_size > MAX_FILE_SIZE:
            raise HTTPException(
                status_code=400,
                detail=f"File size exceeds maximum limit of {MAX_FILE_SIZE/1024/1024}MB"
            )
    
    # Reset file pointer
    file.file.seek(0)
    
    # Check file extension
    file_ext = os.path.splitext(file.filename)[1].lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"File type not allowed. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
        )

@app.post("/upload", response_model=TextExtractionResponse, responses={400: {"model": ErrorResponse}, 500: {"model": ErrorResponse}})
async def upload_file(file: UploadFile = File(...)):
    try:
        # Validate file
        validate_file(file)
        
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
            
            return TextExtractionResponse(
                message="File processed successfully",
                extracted_text=extracted_text,
                file_name=file.filename,
                file_type=os.path.splitext(file.filename)[1]
            )
            
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred while processing the file: {str(e)}"
        )

@app.post("/simplify", response_model=TextSimplificationResponse, responses={400: {"model": ErrorResponse}, 500: {"model": ErrorResponse}})
async def simplify_text(request: TextSimplificationRequest):
    try:
        # Prepare the prompt for text simplification
        prompt = f"""Please simplify the following text for a student with learning challenges. 
        Make it more accessible and easier to understand while maintaining the key information.
        Provide three formats:
        1. A simplified paragraph version
        2. Key bullet points
        3. Step-by-step explanation

        Text to simplify:
        {request.text}

        Please format your response as a JSON object with these keys:
        - simplified_text: The simplified paragraph version
        - bullet_points: Array of key points
        - step_by_step: Array of steps for understanding
        """

        # Call Bedrock API
        response = bedrock_client.invoke_model(
            modelId='anthropic.claude-3-sonnet-20240229-v1:0',
            body=json.dumps({
                "prompt": prompt,
                "max_tokens": 1000,
                "temperature": 0.7
            })
        )

        # Parse the response
        response_body = json.loads(response['body'].read())
        simplified_content = json.loads(response_body['completion'])

        return TextSimplificationResponse(
            simplified_text=simplified_content['simplified_text'],
            bullet_points=simplified_content['bullet_points'],
            step_by_step=simplified_content['step_by_step']
        )

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred while simplifying the text: {str(e)}"
        )

@app.post("/narrate", response_model=NarrationResponse, responses={400: {"model": ErrorResponse}, 500: {"model": ErrorResponse}})
async def narrate_text(request: NarrationRequest):
    try:
        # Call Polly to generate speech
        response = polly_client.synthesize_speech(
            Text=request.text,
            OutputFormat='mp3',
            VoiceId='Joanna'  # You can make this configurable
        )

        # Save the audio file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp3') as temp_file:
            temp_file.write(response['AudioStream'].read())
            temp_file.flush()
            
            # In a production environment, you would upload this to S3
            # For now, we'll return the local file path
            return NarrationResponse(
                audio_url=f"file://{temp_file.name}",
                duration=len(request.text.split()) / 3  # Rough estimate of duration
            )

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred while generating narration: {str(e)}"
        )
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