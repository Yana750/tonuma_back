import 'package:flutter/material.dart';

import '../../widgets/constants.dart';
import '../Order/order_screen.dart';
import '../Provider/cart_provider.dart';

class CheckOutBox extends StatelessWidget {
  const CheckOutBox({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = CartProvider.of(context);

    // Проверяем, пуста ли корзина
    bool isCartEmpty = provider.cart.isEmpty;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              filled: true,
              fillColor: kcontentColor,
              hintText: "Введите промокод",
              hintStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              suffixIcon: TextButton(
                onPressed: () {},
                child: Text(
                  "Применить",
                  style: TextStyle(
                    color: kprimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Всего",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                "${provider.totalPrice()} ₽",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Итого",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "${provider.totalPrice()} ₽",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: isCartEmpty
                ? null  // если корзина пуста, кнопка неактивна
                : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCartEmpty ? Colors.grey : kprimaryColor,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text(
              "Оформить заказ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}