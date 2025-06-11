# AI Nable Backend

This is the backend service for AI Nable, handling PDF uploads and text extraction using Amazon Textract.

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up AWS credentials:
   - Create a `.env` file in the root directory
   - Copy the contents from `.env.example`
   - Fill in your AWS credentials:
   ```
   AWS_ACCESS_KEY_ID=your_access_key_here
   AWS_SECRET_ACCESS_KEY=your_secret_key_here
   AWS_REGION=us-east-1
   ```

## Team Development Guidelines

### Environment Variables
- Never commit the `.env` file to version control
- Each team member should maintain their own `.env` file locally
- Use `.env.example` as a template for required environment variables
- If you need to add new environment variables:
  1. Add them to your local `.env` file
  2. Add them to `.env.example` (without real values)
  3. Update this README if necessary

### AWS Credentials
- Each team member should use their own AWS credentials
- Create an IAM user with appropriate permissions for development
- Required AWS permissions:
  - AmazonTextractFullAccess
  - AmazonS3ReadOnlyAccess (if using S3)

## Running the Server

Start the FastAPI server:
```bash
cd backend
uvicorn main:app --reload
```

The server will start at `http://localhost:8000`

## API Endpoints

- `GET /`: Welcome message
- `POST /upload`: Upload a PDF or image file for text extraction
  - Accepts multipart/form-data with a file field named 'file'
  - Returns extracted text from the document

## AWS Textract Integration

The backend uses Amazon Textract to extract text from uploaded documents. Make sure you have:
1. An AWS account
2. Textract service enabled
3. Proper IAM permissions for Textract
4. Valid AWS credentials in your `.env` file 