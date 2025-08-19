import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';

import '../api/auth_interceptor.dart';
import '../models/product_model.dart';
import 'auth_service.dart';

class OrderService {
  late final AuthService _authService;

  Future<bool> sendOrder({
    required List<Product> cartProducts,
    required double totalPrice,
    required String name,
    required String phone,
    required String address,
    String comment = '',
  }) async {
    final url = Uri.parse('${_authService.baseUrl.replaceAll('/accounts', '')}/orders/send/');

    final body = jsonEncode({
      'positions': _productsToOrderPositions(cartProducts),
      'total_price': totalPrice,
      'name': name,
      'phone': phone,
      'address': address,
      'comment': comment,
    });

    try {
      // Используем клиент из AuthService — он уже с перехватчиком и токеном
      final response = await _authService.client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Заказ отправлен!');
        return true;
      } else {
        print('❌ Ошибка при отправке заказа: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('❗ Исключение при отправке заказа: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> _productsToOrderPositions(List<Product> products) {
    return products.map((product) => {
      'product_id': product.id,
      'quantity': product.quantity,
      // добавь другие поля, если нужно
    }).toList();
  }
}

class Order {
  final String name;
  final String created;
  final double sum;
  final String comment;

  Order({
    required this.name,
    required this.created,
    required this.sum,
    required this.comment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      name: json['name'],
      created: json['created'],
      sum: (json['sum'] as num).toDouble(),
      comment: json['comment'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Order(name: $name, created: $created, sum: $sum, comment: $comment)';
  }
}
