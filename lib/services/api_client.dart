import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, this.token});

  final String baseUrl;
  final String? token;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
      }),
    );
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _headers,
    );
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> merchants() async {
    final res = await http.get(Uri.parse('$baseUrl/merchants'), headers: _headers);
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> services() async {
    final res = await http.get(Uri.parse('$baseUrl/services'), headers: _headers);
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> orders() async {
    final res = await http.get(Uri.parse('$baseUrl/orders'), headers: _headers);
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createOrder({
    required int merchantId,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers,
      body: jsonEncode({'merchant_id': merchantId, 'items': items}),
    );
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> chatRooms() async {
    final res = await http.get(Uri.parse('$baseUrl/chat/rooms'), headers: _headers);
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> chatMessages(int roomId) async {
    final res = await http.get(Uri.parse('$baseUrl/chat/rooms/$roomId/messages'), headers: _headers);
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage({required int roomId, required String text}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/rooms/$roomId/messages'),
      headers: _headers,
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createRoom({required int merchantId}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/rooms'),
      headers: _headers,
      body: jsonEncode({'merchant_id': merchantId}),
    );
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSupportRoom() async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat/support'),
      headers: _headers,
    );
    if (res.statusCode >= 400) {
      throw Exception(res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
