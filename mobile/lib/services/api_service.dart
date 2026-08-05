import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
    );
  }

  static Future<http.Response> uploadFile(String endpoint, String filePath, String fieldName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> postFormData(String endpoint, Map<String, String> fields, [List<MapEntry<String, String>>? files]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll(fields);
    if (files != null) {
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(file.key, file.value));
      }
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<String?> uploadPlatformFile(PlatformFile file) async {
    try {
      final response = await uploadFile('/upload', file.path!, 'file');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fileUrl'];
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }

  static Future<http.Response> putFormData(String endpoint, Map<String, String> fields, [List<MapEntry<String, String>>? files]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll(fields);
    if (files != null) {
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(file.key, file.value));
      }
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
