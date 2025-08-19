import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _cart = [];

  List<Product> get cart => _cart;

  // Метод для добавления товара в корзину
  void addToCart(Product product) {
    final existingProduct = _cart.firstWhere(
          (item) => item.id == product.id,
      orElse: () => Product(id: '', name: '', imageUrls: [], quantity: 0),
    );

    if (existingProduct.id != '') {
      // Если товар найден, увеличиваем его количество
      existingProduct.quantity++;
    } else {
      // Если товара нет в корзине, добавляем новый
      _cart.add(product);
    }

    notifyListeners();
  }

  // Метод для переключения избранного
  void toggleFavorite(Product product) {
    final existingProduct = _cart.firstWhere(
          (item) => item.id == product.id,
      orElse: () => Product(id: '', name: '', imageUrls: [], quantity: 0),
    );

    if (existingProduct.id != '') {
      // Если товар уже в корзине, увеличиваем его количество
      existingProduct.quantity++;
    } else {
      // Если товара нет в корзине, добавляем новый
      _cart.add(product);
    }

    notifyListeners();
  }

  // Увеличение количества товара по индексу
  void incrementQtn(int index) {
    if (index >= 0 && index < _cart.length) {
      _cart[index].quantity++;
      notifyListeners();
    }
  }

  // Уменьшение количества товара по индексу
  void decrementQtn(int index) {
    if (index >= 0 && index < _cart.length && _cart[index].quantity > 1) {
      _cart[index].quantity--;
      notifyListeners();
    }
  }

  // Общая сумма заказа
  double totalPrice() {
    double total = 0.0;
    for (Product element in _cart) {
      total += (element.price ?? 0.0) * element.quantity;
    }
    return total;
  }

  // Статический метод для получения CartProvider
  static CartProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<CartProvider>(context, listen: listen);
  }

  // Метод для очистки корзины
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
