import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // Change if backend is hosted elsewhere

  static Future<Map<String, dynamic>> uploadFile(File file) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(respStr);
    } else {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> simplifyText(String text) async {
    var uri = Uri.parse('$baseUrl/simplify');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Simplification failed');
    }
  }

  static Future<Map<String, dynamic>> narrateText(String text) async {
    var uri = Uri.parse('$baseUrl/narrate');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Narration failed');
    }
  }
}