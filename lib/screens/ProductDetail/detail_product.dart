import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../../models/product_model.dart';
import '../../widgets/constants.dart';
import '../Provider/cart_provider.dart';
import 'Widgets/detail_app_bar.dart';
import 'Widgets/full_screen_image.dart';
import 'Widgets/items_detail.dart';

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<Uint8List> imageBytesList = [];
  bool isLoadingImages = true;
  int currentImage = 0;
  final ScrollController _scrollController = ScrollController();
  bool isAtBottom = false;
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    print("Картинка URLs: ${widget.product.imageUrls}");
    loadProductImages();

    _scrollController.addListener(() {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 20) {
        if (!isAtBottom) {
          setState(() {
            isAtBottom = true;
          });
        }
      } else {
        if (isAtBottom) {
          setState(() {
            isAtBottom = false;
          });
        }
      }
    });
  }

  Future<void> loadProductImages() async {
    if (widget.product.imageUrls.isEmpty) {
      setState(() {
        isLoadingImages = false;
      });
      return;
    }

    try {
      final loadedImages = await Future.wait(
        widget.product.imageUrls.map((url) async {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            return response.bodyBytes;
          } else {
            throw Exception('Ошибка загрузки изображения: ${response.statusCode}');
          }
        }),
      );

      setState(() {
        imageBytesList = loadedImages;
        isLoadingImages = false;
      });
    } catch (e) {
      print('Ошибка загрузки изображений: $e');
      setState(() {
        isLoadingImages = false;
      });
    }
  }

  void onSizeSelected(String? size) {
    setState(() {
      selectedSize = size;
    });
  }

  Widget buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(imageBytesList.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentImage == index ? 10 : 6,
          height: currentImage == index ? 10 : 6,
          decoration: BoxDecoration(
            color: currentImage == index ? Colors.orange : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildFloatingButton() {
    final isDisabled = selectedSize == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
          final cartProvider = CartProvider.of(context, listen: false);

          // Создаём продукт с выбранным размером для добавления в корзину
          final productToAdd = Product(
            id: widget.product.id,
            name: widget.product.name,
            price: widget.product.price,
            imageUrls: widget.product.imageUrls,
            quantity: 1,
            sizes: widget.product.sizes,
            selectedSize: selectedSize,
            description: widget.product.description,
            imageBytes: imageBytesList.isNotEmpty ? imageBytesList[0] : null,
          );

          cartProvider.addToCart(productToAdd);

          Flushbar(
            message: "${widget.product.name} добавлен в корзину!",
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green.shade600,
            borderRadius: BorderRadius.circular(10),
            margin: const EdgeInsets.all(6),
            flushbarPosition: FlushbarPosition.BOTTOM,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            animationDuration: const Duration(milliseconds: 500),
          ).show(context);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
          backgroundColor: isDisabled ? Colors.black45 : Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 6,
        ),
        child: const Text(
          "В корзину",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  DetailAppBar(product: widget.product),
                  const SizedBox(height: 5),
                  isLoadingImages
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: PageView.builder(
                          itemCount: imageBytesList.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentImage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImage(
                                      imageBytes: imageBytesList[index],
                                      tag: 'imageHero$index',
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'imageHero$index',
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      imageBytesList[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildIndicator(),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: ItemsDetails(
                      product: widget.product,
                      selectedSize: selectedSize,
                      onSizeSelected: onSizeSelected,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isAtBottom)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: buildFloatingButton(),
                    ),
                ],
              ),
            ),
            if (!isAtBottom)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: buildFloatingButton(),
              ),
          ],
        ),
      ),
    );
  }
}
