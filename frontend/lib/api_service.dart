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