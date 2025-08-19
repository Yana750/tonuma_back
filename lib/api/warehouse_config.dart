import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class MoySkladConfig {
  final String backendBaseUrl = "http://192.168.0.20:8000";

  // Метод для получения товаров
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('$backendBaseUrl/api/products/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } else {
      throw Exception('Ошибка загрузки с сервера');
    }
  }
}
