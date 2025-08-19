import 'package:flutter/material.dart';

import '../../../widgets/constants.dart';
import '../../../models/product_model.dart';
import '../../Provider/cart_provider.dart';

class AddToCart extends StatefulWidget {
  final Product product;

  const AddToCart({super.key, required this.product});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final provider = CartProvider.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: Colors.black,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (currentIndex != 1) {
                        setState(() {
                          currentIndex--;
                        });
                      }
                    },
                    iconSize: 14,
                    icon: Icon(Icons.remove),
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    currentIndex.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentIndex++;
                      });
                    },
                    iconSize: 14,
                    icon: Icon(Icons.add),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Добавляем товар в корзину
                provider.addToCart(widget.product);

                const snackBar = SnackBar(
                  content: Text(
                    "Успешно добавлено в корзину",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  duration: Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: kprimaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Добавить в корзину",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
