import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';

class AuthInterceptor implements InterceptorContract {
  final storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.0.20:8000/api/accounts';

  @override
  FutureOr<bool> shouldInterceptRequest() => true;

  @override
  FutureOr<bool> shouldInterceptResponse() => true;

  @override
  Future<http.BaseRequest> interceptRequest({
    required http.BaseRequest request,
  }) async {
    final accessToken = await storage.read(key: 'access');

    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    print('Request headers after adding token: ${request.headers}');
    return request;
  }


  @override
  Future<http.BaseResponse> interceptResponse({
    required http.BaseResponse response,
  }) async {
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        await storage.deleteAll();
      }
    }
    return response;
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh');
    if (refreshToken == null) return false;

    final url = Uri.parse('$baseUrl/token/refresh/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'access', value: data['access']);
      if (data.containsKey('refresh')) {
        await storage.write(key: 'refresh', value: data['refresh']);
      }
      return true;
    }

    return false;
  }
}
