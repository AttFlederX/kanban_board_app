import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kanban_board_app/models/auth_response.dart';
import '../config/api_config.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Store JWT token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Retrieve JWT token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Clear JWT token
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Get headers with JWT token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // POST request
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = requiresAuth
        ? await _getHeaders()
        : {'Content-Type': 'application/json'};

    return await http.post(url, headers: headers, body: json.encode(body));
  }

  // GET request
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _getHeaders();

    return await http.get(url, headers: headers);
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _getHeaders();

    return await http.put(url, headers: headers, body: json.encode(body));
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final headers = await _getHeaders();

    return await http.delete(url, headers: headers);
  }

  // Exchange Google ID token for JWT
  static Future<AuthResponse> authenticateWithGoogle(String idToken) async {
    final response = await post('/auth/google', {
      'id_token': idToken,
    }, requiresAuth: false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final resp = AuthResponse.fromJson(data);

      await saveToken(resp.token);

      return resp;
    } else {
      throw Exception('Authentication failed: ${response.body}');
    }
  }
}
