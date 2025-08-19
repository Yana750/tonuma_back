import 'package:flutter/material.dart';

import '../../widgets/constants.dart';
import '../Provider/cart_provider.dart';
import 'check_out.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = CartProvider.of(context);
    final finalList = provider.cart;
    // Количество товара
    productQuantity(IconData icon, int index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            icon == Icons.add
                ? provider.incrementQtn(index)
                : provider.cart[index].quantity > 1
                ? provider.decrementQtn(index)
                : null;
          });
        },
        child: Icon(icon, size: 20),
      );
    }

    return Scaffold(
      //for total and check out
      bottomSheet: CheckOutBox(),
      backgroundColor: kcontentColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      "Корзина",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: finalList.length,
                itemBuilder: (context, index) {
                  final cartItems = finalList[index];
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 15,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                height: 100,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: kcontentColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.all(10),
                                child:
                                    cartItems.imageBytes != null
                                        ? Image.memory(cartItems.imageBytes!)
                                        : const Icon(Icons.image_not_supported),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartItems.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Размер: ${cartItems.selectedSize ?? '-'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "${cartItems.price} \₽",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 35,
                        right: 25,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                finalList.removeAt(index);
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.delete_outline_outlined,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: kcontentColor,
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 10),
                                  productQuantity(Icons.remove, index),
                                  SizedBox(width: 10),
                                  Text(
                                    cartItems.quantity.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  productQuantity(Icons.add, index),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
