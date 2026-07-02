import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      headers['X-Auth-Token'] = _token!;
      headers['token'] = _token!;
    }
    print('API Headers: $headers'); // Debug log
    return headers;
  }

  Map<String, String> get _formHeaders {
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      headers['X-Auth-Token'] = _token!;
      headers['token'] = _token!;
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('ApiService.get - Token: $_token'); // Debug log
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final requestBody = _addTokenToBody(body);
      final encoded = requestBody != null ? jsonEncode(requestBody) : null;
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: encoded,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> postForm(
    String endpoint, {
    required Map<String, String> body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _formHeaders,
            body: _addTokenToFormBody(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final requestBody = _addTokenToBody(body);
      final encoded = requestBody != null ? jsonEncode(requestBody) : null;
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: encoded,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> uploadMultipart(
    String endpoint, {
    required String filePath,
    required String fieldName,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization headers
      if (_token != null && _token!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_token';
        request.headers['token'] = _token!;
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Map<String, dynamic>? _addTokenToBody(Map<String, dynamic>? body) {
    if (_token == null || _token!.isEmpty) {
      return body;
    }

    return {if (body != null) ...body, 'token': _token};
  }

  Map<String, String> _addTokenToFormBody(Map<String, String> body) {
    if (_token == null || _token!.isEmpty) {
      return body;
    }

    return {...body, 'token': _token!};
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(response.body);
      // Recursively convert any BigInt values to int/num so the result
      // can be safely passed to jsonEncode later (e.g. when logging or
      // building subsequent request bodies).
      final sanitized = _sanitizeJson(decoded);
      if (sanitized is Map<String, dynamic>) {
        data = sanitized;
      } else {
        data = {'message': sanitized.toString()};
      }
    } catch (e) {
      // Server returned non-JSON (HTML error page, plain text, empty body, etc.)
      final preview = response.body.length > 200
          ? '${response.body.substring(0, 200)}...'
          : response.body;
      print(
        'API Non-JSON Response - Status: ${response.statusCode}, Body: $preview',
      ); // Debug log
      throw ApiException(
        'Server returned non-JSON response (status ${response.statusCode}): $preview',
        response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
        'API Success - Status: ${response.statusCode}, Keys: ${data.keys.toList()}',
      ); // Debug log
      return data;
    } else {
      final message =
          data['message'] ?? data['error'] ?? 'Unknown error occurred';
      print(
        'API Error - Status: ${response.statusCode}, Message: $message, Body: ${response.body}',
      ); // Debug log
      throw ApiException(message, response.statusCode);
    }
  }

  /// Recursively walks a decoded JSON tree and converts any [BigInt] values
  /// to plain [int] (or [num] when they exceed 64-bit range) so the result
  /// is safe to pass back through [jsonEncode].
  dynamic _sanitizeJson(dynamic value) {
    if (value is BigInt) {
      // Try to fit into a 64-bit int; otherwise keep as a numeric string
      // so it can still be encoded as JSON.
      try {
        return value.toInt();
      } catch (_) {
        return value.toString();
      }
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _sanitizeJson(v)));
    }
    if (value is List) {
      return value.map(_sanitizeJson).toList();
    }
    return value;
  }
}
