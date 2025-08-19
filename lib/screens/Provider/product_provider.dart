import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_client.dart';

import '../../models/product_model.dart';
import '../../api/auth_interceptor.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // Используем InterceptedClient с AuthInterceptor
  final client = InterceptedClient.build(interceptors: [AuthInterceptor()]);

  Future<void> loadProducts() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('http://192.168.0.20:8000/api/products/');
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final List<Product> fetchedProducts = await Future.wait(jsonData.map((item) async {
          final product = Product.fromJson(item);

          if (product.imageUrls.isNotEmpty) {
            try {
              final imgResp = await client.get(Uri.parse(product.imageUrls[0]));
              if (imgResp.statusCode == 200) {
                product.imageBytes = imgResp.bodyBytes;
              }
            } catch (e) {
              print('Ошибка загрузки изображения: $e');
            }
          }

          return product;
        }).toList());

        _products = fetchedProducts;
      } else {
        print('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка загрузки продуктов: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
