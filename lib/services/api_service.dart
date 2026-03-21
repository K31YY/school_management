import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungthoung_app/core/config.dart';
import 'package:ungthoung_app/providers/auth_provider.dart';

class ApiService {
  final Ref _ref;

  ApiService(this._ref);

  Map<String, String> _getHeaders() {
    final token = _ref.read(authProvider).token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${Config.baseUrl}/$endpoint');
    return await http.get(url, headers: _getHeaders());
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Config.baseUrl}/$endpoint');
    return await http.post(url, headers: _getHeaders(), body: jsonEncode(body));
  }

  // Add more methods like multipart post if needed
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});
