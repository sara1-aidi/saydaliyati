import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// An error with a message that is safe to show to the user.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Small wrapper around `http` : base URL, JSON, Bearer token, error handling.
class ApiClient {
  ApiClient({required this.tokenReader, this.onUnauthorized});

  final String? Function() tokenReader;
  final void Function()? onUnauthorized; // called when the token is rejected

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool auth = true,
  }) async {
    final token = auth ? tokenReader() : null;
    final uri = Uri.parse('$kApiBaseUrl$path')
        .replace(queryParameters: query == null || query.isEmpty ? null : query);

    final request = http.Request(method, uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    late http.Response res;
    try {
      final streamed = await request.send().timeout(const Duration(seconds: 10));
      res = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('The server took too long to respond.');
    } catch (_) {
      throw ApiException(
          'Cannot reach the server. Check that the API is running and the address in api_config.dart is correct.');
    }

    dynamic data;
    if (res.bodyBytes.isNotEmpty) {
      try {
        data = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        data = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    if (res.statusCode == 401 && token != null) onUnauthorized?.call();
    throw ApiException(_messageFrom(data, res.statusCode), statusCode: res.statusCode);
  }

  String _messageFrom(dynamic data, int status) {
    if (data is Map && data['detail'] is String) return data['detail'] as String;
    return 'Something went wrong (error $status).';
  }
}
