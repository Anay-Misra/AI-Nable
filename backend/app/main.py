from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import boto3
import os
from dotenv import load_dotenv
import tempfile

# Load environment variables
load_dotenv()

app = FastAPI(
    title="AI Nable Backend",
    description="Backend service for AI Nable, handling PDF uploads and text extraction using Amazon Textract",
    version="1.0.0"
)

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

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    """
    Upload a PDF or image file and extract text using Amazon Textract
    """
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

@app.get("/")
async def root():
    """
    Root endpoint - Welcome message
    """
    return {
        "message": "Welcome to AI Nable Backend",
        "version": "1.0.0",
        "endpoints": {
            "root": "/",
            "upload": "/upload",
            "docs": "/docs"
        }
    } 