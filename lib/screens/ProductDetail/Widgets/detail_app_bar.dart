import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../../Provider/favorite_provider.dart';

class DetailAppBar extends StatefulWidget {
  final Product product;

  const DetailAppBar({super.key, required this.product});

  @override
  State<DetailAppBar> createState() => _DetailAppBarState();
}

class _DetailAppBarState extends State<DetailAppBar> {
  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final isFavorite = provider.isExist(widget.product);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(
            alignment: Alignment.center,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          const Spacer(),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
            onPressed: () {
              // Пока оставим пустым для шаринга
            },
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 10),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
            onPressed: () {
              provider.toggleFavorite(widget.product);
              setState(() {}); // <<< Перерисовываем кнопку после нажатия
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}