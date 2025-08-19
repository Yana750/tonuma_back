import 'package:flutter/material.dart';
import '../../../widgets/constants.dart';
import '../../../models/product_model.dart';

class ItemsDetails extends StatefulWidget {
  final Product product;
  final String? selectedSize;
  final Function(String?) onSizeSelected;

  const ItemsDetails({
    super.key,
    required this.product,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  State<ItemsDetails> createState() => _ItemsDetailsState();
}

class _ItemsDetailsState extends State<ItemsDetails> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 10),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.price != null ? "${product.price!.toStringAsFixed(2)} ₽" : "Цена не указана",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: kprimaryColor,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: const Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          // Здесь можно добавить рейтинг
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        if (product.sizes.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text("Доступные размеры:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: product.sizes.map((sizeInfo) {
              final isSelected = sizeInfo.size == widget.selectedSize;
              final isOutOfStock = sizeInfo.stock == 0;

              return ChoiceChip(
                label: Text("${sizeInfo.size} (${sizeInfo.stock})"),
                selected: isSelected,
                selectedColor: kprimaryColor,
                backgroundColor: isOutOfStock ? Colors.grey.shade300 : Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isOutOfStock
                      ? Colors.grey
                      : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: isOutOfStock
                    ? null
                    : (selected) {
                  final selectedValue = selected ? sizeInfo.size : null;
                  widget.onSizeSelected(selectedValue);
                },
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 20),
        const Text("Описание", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          product.description ?? "Описание отсутствует",
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
