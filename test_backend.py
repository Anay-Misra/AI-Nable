#!/usr/bin/env python3
"""
Test script to verify backend fixes for PDF upload and visual storytelling issues.
"""

import requests
import json
import time

# Backend URL
BASE_URL = "http://localhost:8000"

def test_backend_health():
    """Test if the backend is running."""
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"✅ Backend health check: {response.status_code}")
        print(f"Response: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Backend health check failed: {e}")
        return False

def test_visual_storytelling():
    """Test visual storytelling with a long text to ensure it stays within limits."""
    print("\n🧪 Testing Visual Storytelling...")
    
    # Create a long text that would exceed the 512 character limit
    long_text = """
    The solar system is a vast collection of celestial bodies that orbit around the Sun. 
    It consists of eight planets: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, and Neptune. 
    Each planet has unique characteristics and features that make them fascinating objects of study. 
    The inner planets are rocky and close to the Sun, while the outer planets are gas giants. 
    There are also many smaller objects like asteroids, comets, and dwarf planets. 
    The solar system formed about 4.6 billion years ago from a giant cloud of gas and dust.
    """
    
    try:
        # First simplify the text
        simplify_response = requests.post(f"{BASE_URL}/simplify", json={"text": long_text})
        print(f"Simplify response status: {simplify_response.status_code}")
        
        if simplify_response.status_code == 200:
            simplified_data = simplify_response.json()
            simplified_text = simplified_data.get("simplified_text", "")
            print(f"Simplified text length: {len(simplified_text)} characters")
            print(f"Simplified text preview: {simplified_text[:100]}...")
            
            # Now test visual model generation
            visual_response = requests.post(f"{BASE_URL}/visual-model", json={"simplified_text": simplified_text})
            print(f"Visual model response status: {visual_response.status_code}")
            
            if visual_response.status_code == 200:
                visual_data = visual_response.json()
                print("✅ Visual storytelling test passed!")
                print(f"Generated image base64 length: {len(visual_data.get('image_base64', ''))}")
            else:
                print(f"❌ Visual model generation failed: {visual_response.text}")
        else:
            print(f"❌ Text simplification failed: {simplify_response.text}")
            
    except Exception as e:
        print(f"❌ Visual storytelling test failed: {e}")

def test_error_handling():
    """Test error handling for unsupported document formats."""
    print("\n🧪 Testing Error Handling...")
    
    # Test with an empty file upload (should fail gracefully)
    try:
        # Create a minimal test file
        test_content = b"test content"
        files = {"file": ("test.txt", test_content, "text/plain")}
        
        response = requests.post(f"{BASE_URL}/upload", files=files)
        print(f"Upload response status: {response.status_code}")
        
        if response.status_code == 400:
            print("✅ Error handling test passed - correctly rejected unsupported file type")
        else:
            print(f"⚠️ Unexpected response: {response.status_code}")
            
    except Exception as e:
        print(f"❌ Error handling test failed: {e}")

def test_audio_narration():
    """Test audio narration functionality."""
    print("\n🧪 Testing Audio Narration...")
    
    test_text = "Hello, this is a test of the audio narration feature. Tobi is here to help you learn!"
    
    try:
        response = requests.post(f"{BASE_URL}/narrate", json={"text": test_text})
        print(f"Narration response status: {response.status_code}")
        
        if response.status_code == 200:
            response_data = response.json()
            audio_base64 = response_data.get('audio_base64', '')
            print(f"✅ Audio narration test passed!")
            print(f"Generated audio base64 length: {len(audio_base64)}")
            print(f"Audio data preview: {audio_base64[:50]}...")
        else:
            print(f"❌ Audio narration failed: {response.text}")
            
    except Exception as e:
        print(f"❌ Audio narration test failed: {e}")

def main():
    """Run all tests."""
    print("🚀 Starting Backend Tests...")
    
    # Wait a moment for backend to start
    time.sleep(2)
    
    # Test backend health
    if not test_backend_health():
        print("❌ Backend is not running. Please start the backend first.")
        return
    
    # Test visual storytelling
    test_visual_storytelling()
    
    # Test error handling
    test_error_handling()
    
    # Test audio narration
    test_audio_narration()
    
    print("\n✅ All tests completed!")

if __name__ == "__main__":
    main() 