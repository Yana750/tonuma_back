import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';

import '../api/auth_interceptor.dart';

class BackendService {
  static const String _baseUrl = 'http://192.168.0.20:8000/api';

  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  final http.Client client = InterceptedClient.build(
    interceptors: [AuthInterceptor()],
  );

  /// Отправить заказ
  static Future<bool> sendOrder(Map<String, dynamic> orderData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/send-order/'),
      headers: _headers(),
      body: jsonEncode(orderData),
    );
    return response.statusCode == 200;
  }

  /// Получить заказы по телефону
  static Future<List<Map<String, dynamic>>> getOrdersByPhone(String phone) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/orders/?phone=$phone'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Ошибка получения заказов');
    }
  }

  /// Получить детали товара по ссылке
  static Future<Map<String, dynamic>?> fetchProductDetails(String productUrl) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/product-details/?url=${Uri.encodeComponent(productUrl)}'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
