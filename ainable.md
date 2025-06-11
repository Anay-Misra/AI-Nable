What is AI-NABLE? 
An app that helps neurodiverse students, especially those with ADHD, dyslexia, or low literacy, understand complex educational materials using generative AI, voice, and visual storytelling.

Our mascot: 
Students with learning challenges often face anxiety, shame, and fear of failure. A friendly mascot: 
Reduces imitation 
Feels like a supportive friend 
Makes the journey more personal 
Improves attention and retention for ADHD 

Name suggestions? 
Snap Study
Buddy Book 
Clarity Class
Tobi Talks 

Phase 1: Planning & Set-up 

User flow: 

STEP 
DESCRIPTION 
AWS SERVICE 
Upload 
The user uploads a textbook page or a lecture PDF 
Amazon Textract 
Extraction 
App extracts text from the file 
Amazon Textract 
Simplification 
Text is simplified using/literacy-appropriate LLM models 
Amazon Bedrock  
Narration 
Polly reads the simplified version out loud 
Amazon Polly 
Visual Model 
A summary is turned into a visual step-by-step diagram 
Bedrock ( for storytelling), image tools 
Q&A
The user asks questions about the topic 
Amazon Bedrock/Q
Save + Export 
User downloads audios and shares with peers 





Features: 

Login/Sign up: 
Email and password authentication 
First time onboarding popup: “Welcome to AI-Nable! Ready to learn your way?”
Forgot password + reset options 

Dashboard: 
My summers: view all simplified text outputs 
My audio files: access all generated audio files 
Favorites: revisit favorite lessons 
Settings: accessibility features → logout button 
Upload new file → for first-time users, go straight away to upload a new file by saying “Welcome! You do not have any files yet. Let's start by uploading your first lesson!” 
Tobi the tutor teddy every step of the way, with the user giving motivation 

Upload File and Preview 
Upload PDF/image files 
Drag and drop or file picker 
Accept .pdf, .jpg, .png
Show file thumbnail or filename 
Progress indicator → “Step 1 of 4” 

Text Extraction 
Extract text from PDF/image
Display the extracted text for user preview
 Button: Simplify this

LLM-Based Text Simplification 
Simplify the test 
Output: 
Simplified paragraph version 
Bullet point summary 
Step-by-step explanation 
Tabs → summary, definitions, steps 
Buttons → Simplify again, make even simpler 

Audio Narration 
Generate text-to-speech
Audio player: 
play/pause 
Playback speed
Voice options (male/female, regional accents) 
Visual sync: highlight words/sentences as they r read
Download audio button 

Visual Storytelling (optional) 
Turn the summary into a visual format 

Chatbot/ask a question 
Q&A chatbot 

Favorite any session 

Offline 
Save the summary/audio locally for offline viewing


Roles: 

Frontend Developer → Build UI  → Anvesha and Saksham 
Backend Developer → API routes, AWS Integration → Anay and Sanskriti
Prompt Engineer → Design and Test LLM Prompts for simplification → Saksham with help of Anay
Designer → create Figma mockups of each screen → Anvesha 
Everyone → video + other submission stuff 



      Tobi The Tutor Bear: 

Tobi can react based on student progress: Clap after successful simplification,  Give a thumbs-up or hold up a "Well done!" sign

