import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../models/address_model.dart';
import '../api/auth_interceptor.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.0.20:8000/api/accounts';

  // Создаем клиент с перехватчиком
  final http.Client client = InterceptedClient.build(
    interceptors: [
      AuthInterceptor(),
    ],
  );

  Future<String?> register(String username, String phone, String password, String password2) async {
    final url = Uri.parse('$baseUrl/register/');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'phone': phone,
        'password': password,
        'password2': password2,
      }),
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      final data = json.decode(response.body);
      if (data is Map) {
        return data.entries.map((e) {
          final value = e.value;
          if (value is List) return '${e.key}: ${value.join(", ")}';
          return '${e.key}: $value';
        }).join('\n');
      }
      return 'Ошибка регистрации';
    }
  }

  Future<String?> login(String phone, String password) async {
    final url = Uri.parse('$baseUrl/token/');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'access', value: data['access']);
      await storage.write(key: 'refresh', value: data['refresh']);
      return null;
    } else {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('detail')) {
        return data['detail'];
      }
      return 'Ошибка входа';
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access');
    await storage.delete(key: 'refresh');
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access');
  }

  bool _isTokenExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> payloadMap = json.decode(decoded);

    final exp = payloadMap['exp'];
    if (exp == null) return true;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await storage.read(key: 'refresh');
    if (refreshToken == null) return false;

    final url = Uri.parse('$baseUrl/token/refresh/');
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'access', value: data['access']);
      if (data.containsKey('refresh')) {
        await storage.write(key: 'refresh', value: data['refresh']);
      }
      return true;
    } else {
      await logout();
      return false;
    }
  }

  Future<String?> getValidAccessToken() async {
    String? accessToken = await storage.read(key: 'access');

    if (accessToken == null) return null;

    if (_isTokenExpired(accessToken)) {
      final refreshed = await refreshAccessToken();
      if (!refreshed) return null;
      accessToken = await storage.read(key: 'access');
    }

    return accessToken;
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final url = Uri.parse('$baseUrl/me/');
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Ошибка получения данных: ${response.body}');
      return null;
    }
  }

  Future<bool?> updateUserData(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/me/update/');
    final response = await client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Ошибка обновления данных: ${response.body}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/me/');
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'address': data['address'] ?? '',
        'delivery_type': data['delivery_type'] ?? 'incity',
      };
    } else {
      print('Ошибка получения данных пользователя: ${response.body}');
      return null;
    }
  }

  Future<List<Address>?> getAddresses() async {
    final url = Uri.parse('$baseUrl/addresses/');
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => Address.fromJson(jsonItem)).toList();
    } else {
      print('Failed to load addresses: ${response.statusCode} ${response.body}');
      return null;
    }
  }

  Future<bool> updateOrCreateAddress(Map<String, dynamic> data, {int? id}) async {
    Uri url = id != null
        ? Uri.parse('$baseUrl/addresses/$id/')
        : Uri.parse('$baseUrl/addresses/');

    final response = await (id == null
        ? client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    )
        : client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    ));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Ошибка обновления адреса: ${response.statusCode} ${response.body}');
      return false;
    }
  }
}
