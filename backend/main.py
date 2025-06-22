from fastapi import FastAPI, UploadFile, File, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import boto3
import os
from dotenv import load_dotenv
import tempfile
from typing import Optional, List
import logging
import json
import base64

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
MAX_FILE_SIZE = 25 * 1024 * 1024  # 25MB
ALLOWED_EXTENSIONS = {'.pdf', '.jpg', '.jpeg', '.png'}

# Response Models
class TextExtractionResponse(BaseModel):
    message: str
    extracted_text: str
    file_name: str
    file_type: str

class TextSimplificationResponse(BaseModel):
    simplified_text: str
    key_terms: List[dict]
    step_by_step: List[str]

class NarrationResponse(BaseModel):
    audio_base64: str

class ErrorResponse(BaseModel):
    detail: str

class TextSimplificationRequest(BaseModel):
    text: str

class NarrationRequest(BaseModel):
    text: str

class VisualizeRequest(BaseModel):
    step_by_step: List[str]

class VisualizeResponse(BaseModel):
    steps: List[str]
    image_prompts: List[str]
    image_urls: List[str]

class QARequest(BaseModel):
    context: str
    question: str

class QAResponse(BaseModel):
    answer: str

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

polly_client = boto3.client(
    'polly',
    aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
    region_name=os.getenv('AWS_REGION', 'us-east-1')
)

@app.post("/upload", response_model=TextExtractionResponse, responses={400: {"model": ErrorResponse}, 500: {"model": ErrorResponse}})
async def upload_file(file: UploadFile = File(...)):
    try:
        # 1. Read the file content ONCE to avoid stream issues
        content = await file.read()

        # 2. Validate file size from the content we just read
        if len(content) > MAX_FILE_SIZE:
            error_msg = f"File size exceeds maximum limit of {MAX_FILE_SIZE/1024/1024:.1f}MB"
            logger.error(f"Upload failed for {file.filename}: {error_msg}")
            raise HTTPException(status_code=400, detail=error_msg)

        # 3. Validate file extension from the filename
        file_ext = os.path.splitext(file.filename)[1].lower()
        if file_ext not in ALLOWED_EXTENSIONS:
            error_msg = f"File type '{file_ext}' not allowed. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
            logger.error(f"Upload failed for {file.filename}: {error_msg}")
            raise HTTPException(status_code=400, detail=error_msg)

        # 4. Process the file using the 'content' variable
        try:
            response = textract_client.detect_document_text(
                Document={'Bytes': content}
            )
            
            # Extract text from response
            extracted_text = ' '.join([item['Text'] for item in response['Blocks'] if item['BlockType'] == 'LINE'])
            
            # Check if we got any text
            if not extracted_text.strip():
                raise HTTPException(
                    status_code=400, 
                    detail="No text could be extracted from this document. Please ensure the document contains readable text."
                )
            
        except textract_client.exceptions.UnsupportedDocumentException:
            logger.warning(f"Unsupported document format for {file.filename}")
            raise HTTPException(
                status_code=400,
                detail="This document format is not supported by our text extraction service. Please try: 1) A different PDF file, 2) An image file (JPG, PNG), or 3) Ensure the PDF contains readable text (not scanned images)."
            )
        except textract_client.exceptions.DocumentTooLargeException:
            logger.warning(f"Document too large for {file.filename}")
            raise HTTPException(
                status_code=400,
                detail="This document is too large to process. Please try a smaller file (under 25MB) or split the document into smaller parts."
            )
        except textract_client.exceptions.BadDocumentException:
            logger.warning(f"Bad document format for {file.filename}")
            raise HTTPException(
                status_code=400,
                detail="The document appears to be corrupted or in an unsupported format. Please try a different file."
            )
        except Exception as textract_error:
            logger.error(f"Textract error for {file.filename}: {textract_error}")
            raise HTTPException(
                status_code=500,
                detail="Failed to extract text from the document. This might be due to the document format or content. Please try a different file."
            )
        
        return TextExtractionResponse(
            message="File processed successfully",
            extracted_text=extracted_text,
            file_name=file.filename,
            file_type=file_ext
        )
            
    except HTTPException as he:
        # Re-raise validation exceptions
        raise he
    except Exception as e:
        # Log the full traceback for any other unexpected errors
        logger.error(f"An unexpected error occurred processing {file.filename}: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="An unexpected server error occurred while processing the file."
        )

@app.post("/simplify")
async def simplify_text(request: dict):
    try:
        text = request.get("text", "")
        file_name = request.get("file_name", "Unknown file")
        if not text:
            raise HTTPException(status_code=400, detail="Text to simplify cannot be empty.")

        logger.info(f"Simplifying text for: {file_name}")

        # Final, extremely strict prompt to force JSON output
        prompt = f"""Your task is to convert the following text into a valid JSON object.
Your response MUST start with `{{` and end with `}}`. Do not include any other text, comments, or markdown.

<text_to_convert>
{text}
</text_to_convert>

The JSON object must have these exact keys:
- "simplified_text": A simple paragraph using common words.
- "key_terms": An array of objects, each with a "term" and a "definition".
- "step_by_step": An array of strings explaining the process step-by-step.
"""

        response = bedrock_client.invoke_model(
            modelId='anthropic.claude-3-haiku-20240307-v1:0',
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 2048,
                "messages": [
                    {
                        "role": "user",
                        "content": [{"type": "text", "text": prompt}]
                    }
                ]
            })
        )
        
        response_body = json.loads(response['body'].read())
        generated_text = response_body.get('content', [{}])[0].get('text', '{}').strip()

        # Most robust JSON parsing method
        try:
            import re
            # Use regex to find the JSON block, even with leading/trailing text
            match = re.search(r'{.*}', generated_text, re.DOTALL)
            if match:
                json_str = match.group(0)
                simplified_content = json.loads(json_str)
            else:
                raise ValueError("No valid JSON object found in the model's response via regex.")
        except (json.JSONDecodeError, ValueError, ImportError) as e:
            logger.error(f"Final attempt to parse JSON failed for {file_name}: {e}\\nResponse text: {generated_text}")
            simplified_content = {
                "simplified_text": "Tobi had trouble simplifying this text. Please try again with a different document.",
                "key_terms": [],
                "step_by_step": []
            }
        
        return simplified_content

    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"An unexpected error occurred in /simplify for {file_name}: {e}", exc_info=True)
        return JSONResponse(status_code=500, content={"error": "An internal server error occurred during simplification."})

@app.post("/visual-model")
async def generate_visual_model(request: Request):
    try:
        body = await request.json()
        simplified_text = body.get("simplified_text", "")

        if not simplified_text:
            raise HTTPException(status_code=400, detail="Missing 'simplified_text' in request.")

        # Calculate available space for the content text
        # Base prompt: "Colorful minimalist vector illustration, simple icon, vibrant colors, high contrast. A clean visual representation of: "
        # Base prompt length: ~120 characters
        # Suffix: "Solid color background. Absolutely no words, no letters, no text, no numbers."
        # Suffix length: ~85 characters
        # Total base prompt: ~205 characters
        # Available for content: 512 - 205 = 307 characters
        max_content_length = 300  # Leave some buffer
        
        # Truncate the simplified text to fit within the limit
        image_prompt_text = simplified_text[:max_content_length]
        if len(simplified_text) > max_content_length:
            # Try to truncate at a word boundary
            last_space = image_prompt_text.rfind(' ')
            if last_space > max_content_length * 0.7:  # If we can find a good break point
                image_prompt_text = image_prompt_text[:last_space]

        # Create the prompt with proper length control
        prompt = (
            f"Colorful minimalist vector illustration, simple icon, vibrant colors, high contrast. "
            f"A clean visual representation of: {image_prompt_text}. "
            f"Solid color background. Absolutely no words, no letters, no text, no numbers."
        )

        # Verify the total prompt length
        if len(prompt) > 512:
            # Emergency truncation if still too long
            excess = len(prompt) - 512
            image_prompt_text = image_prompt_text[:-excess-10]  # Leave some buffer
            prompt = (
                f"Colorful minimalist vector illustration, simple icon, vibrant colors, high contrast. "
                f"A clean visual representation of: {image_prompt_text}. "
                f"Solid color background. Absolutely no words, no letters, no text, no numbers."
            )

        # Log the final prompt length for debugging
        logger.info(f"Visual model prompt length: {len(prompt)} characters")
        logger.info(f"Visual model prompt: {prompt[:100]}...")

        # The most exhaustive negative prompt I can create to fight text generation.
        negative_prompt = (
            "text, words, letters, numbers, writing, signature, watermark, labels, charts, graphs, text blocks, sentences, paragraphs, fonts, typography, characters, symbols, script, calligraphy, logotype, "
            "ugly, deformed, noisy, blurry, distorted, low resolution, "
            "complex, complicated, busy, cluttered, detailed background, distracting elements, "
            "photorealistic, 3d render, shadows, gradients, violence, nudity, unsafe content, realistic people"
        )

        try:
            response = bedrock_client.invoke_model(
                modelId="amazon.titan-image-generator-v2:0",
                body=json.dumps({
                    "taskType": "TEXT_IMAGE",
                    "textToImageParams": {
                        "text": prompt,
                        "negativeText": negative_prompt
                    },
                    "imageGenerationConfig": {
                        "numberOfImages": 1,
                        "quality": "standard",
                        "height": 512,
                        "width": 512,
                        "cfgScale": 8.0,
                    },
                }),
                contentType="application/json",
                accept="application/json",
            )
            
            response_data = json.loads(response["body"].read())
            base64_image = response_data["images"][0]

            return {
                "title": "Visual Summary",
                "description": "Here is a visual summary of the key concepts.",
                "image_base64": base64_image,
            }
        except bedrock_client.exceptions.ValidationException as ve:
            logger.error(f"Validation error in visual model generation: {ve}")
            raise HTTPException(
                status_code=400,
                detail="The text is too long for image generation. Please try with a shorter text."
            )
        except Exception as bedrock_error:
            logger.error(f"Bedrock error in visual model generation: {bedrock_error}")
            raise HTTPException(
                status_code=500,
                detail="Failed to generate the visual model. Please try again."
            )
    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"An unexpected error occurred in /visual-model: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="An error occurred while generating the visual model."
        )

@app.post("/narrate", response_model=NarrationResponse)
async def narrate_text(request: NarrationRequest):
    try:
        logger.info(f"Narrating text of length: {len(request.text)} characters")
        logger.info(f"Text preview: {request.text[:100]}...")
        
        response = polly_client.synthesize_speech(
            Text=request.text,
            OutputFormat='mp3',
            VoiceId='Joanna'  # A clear, standard voice
        )
        
        audio_stream = response.get("AudioStream")
        if audio_stream:
            audio_base64 = base64.b64encode(audio_stream.read()).decode('utf-8')
            logger.info(f"Successfully generated audio, base64 length: {len(audio_base64)}")
            return NarrationResponse(audio_base64=audio_base64)
        else:
            logger.error("Polly did not return an audio stream")
            raise HTTPException(status_code=500, detail="Polly did not return an audio stream.")

    except Exception as e:
        logger.error(f"An error occurred in /narrate: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to generate audio: {str(e)}")

@app.post("/ask-questions")
async def ask_question(request: dict):
    try:
        context = request.get("context", "")
        question = request.get("question", "")
        #prompt for the question-answering model with context and question
        prompt = f"""You are a helpful tutor for students with learning differences.
Using the following educational material, answer the student's question clearly and simply.

Context:
{context}

Student's question:
{question}

Answer:"""

        response = bedrock_client.invoke_model(
            modelId = 'meta.llama3-8b-instruct-v1:0', # LLaMA 3 model ID
            body = json.dumps({
                "prompt": prompt,
                "max_gen_len": 512,
                "temperature": 0.7
            })
        )

        response_body = json.loads(response['body'].read())
        answer = response_body.get("generation", "I'm not sure how to answer that.")
        
        #return original questions and answer
        return {"question": question, "answer": answer}

    except Exception as e:
        return {"error": str(e)}

@app.get("/")
async def root():
    return {"message": "Welcome to AI Nable Backend"} 