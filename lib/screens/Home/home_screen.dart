import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ProductDetail/detail_product.dart';
import '../Provider/product_provider.dart';
import 'Widgets/home_app_bar.dart';
import 'Widgets/image_slider.dart';
import 'Widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imageUrls = [
    'https://rnqtsxxbnmuxdvqvvzjz.supabase.co/storage/v1/object/public/images/y.png',
    'https://rnqtsxxbnmuxdvqvvzjz.supabase.co/storage/v1/object/public/images/logo.png',
    'https://rnqtsxxbnmuxdvqvvzjz.supabase.co/storage/v1/object/public/images/R.png',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;
    final isLoading = productProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),
            const CustomAppBar(),
            const SizedBox(height: 10),
            const MySearchBAR(),
            const SizedBox(height: 15),
            ImageSlider(imageUrls: imageUrls),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Специально для Вас",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: product.imageUrls.isNotEmpty
                              ? Image.network(
                            product.imageUrls.first,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
                            ),
                          )
                              : Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "${product.price?.toStringAsFixed(2) ?? '0.00'} ₽",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
