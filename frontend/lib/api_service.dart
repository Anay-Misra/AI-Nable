import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // Change if backend is hosted elsewhere

  // Upload file and extract text
  static Future<Map<String, dynamic>> uploadFile(File file) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(respStr);
    } else {
      final errorBody = json.decode(respStr);
      throw Exception('Upload failed: ${errorBody['detail'] ?? respStr}');
    }
  }

  // Simplify text using AI
  static Future<Map<String, dynamic>> simplifyText(String text, String fileName) async {
    var uri = Uri.parse('$baseUrl/simplify');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'file_name': fileName}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Simplification failed: ${response.statusCode}');
    }
  }

  // Generate visual model from simplified text
  static Future<Map<String, dynamic>> generateVisualModel(String simplifiedText) async {
    var uri = Uri.parse('$baseUrl/visual-model');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'simplified_text': simplifiedText}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Visual model generation failed: ${response.statusCode}');
    }
  }

  // Ask questions about educational content
  static Future<Map<String, dynamic>> askQuestion(String context, String question) async {
    var uri = Uri.parse('$baseUrl/ask-questions');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'context': context, 'question': question}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to ask question: ${response.statusCode}');
    }
  }

  // Narrate text using Polly
  static Future<String> narrateText(String text) async {
    // Amazon Polly has a 3000 character limit per request
    const maxCharsPerRequest = 3000;
    
    if (text.length <= maxCharsPerRequest) {
      // Single request for short text
      return await _narrateTextChunk(text);
    } else {
      // Split long text into chunks and concatenate
      print("Text is ${text.length} characters, splitting into chunks...");
      List<String> chunks = [];
      int start = 0;
      
      while (start < text.length) {
        int end = start + maxCharsPerRequest;
        if (end > text.length) {
          end = text.length;
        } else {
          // Try to break at a sentence boundary within the chunk
          String chunkText = text.substring(start, end);
          int lastPeriod = chunkText.lastIndexOf('.');
          int lastExclamation = chunkText.lastIndexOf('!');
          int lastQuestion = chunkText.lastIndexOf('?');
          int lastBreak = [lastPeriod, lastExclamation, lastQuestion]
              .where((i) => i > maxCharsPerRequest * 0.7) // Only break if it's in the last 30% of the chunk
              .fold(-1, (a, b) => a > b ? a : b);
          
          if (lastBreak > 0) {
            end = start + lastBreak + 1; // Include the punctuation
          }
        }
        
        chunks.add(text.substring(start, end));
        start = end;
      }
      
      print("Split into ${chunks.length} chunks");
      
      // For now, just narrate the first chunk to avoid complexity
      // In a full implementation, you'd concatenate all audio chunks
      return await _narrateTextChunk(chunks.first);
    }
  }
  
  // Helper method to narrate a single text chunk
  static Future<String> _narrateTextChunk(String text) async {
    var uri = Uri.parse('$baseUrl/narrate');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['audio_base64'];
    } else {
      throw Exception('Failed to narrate text: ${response.statusCode}');
    }
  }

  // Test backend connection
  static Future<Map<String, dynamic>> testConnection() async {
    var uri = Uri.parse('$baseUrl/');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Backend connection failed: ${response.statusCode}');
    }
  }
}