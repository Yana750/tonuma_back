import 'dart:typed_data';

class Product {
  String id;
  String name;
  double? price;
  List<String> imageUrls;
  Uint8List? imageBytes;
  String? description;
  int quantity;
  List<SizeInfo> sizes;
  String? selectedSize;

  Product({
    required this.id,
    required this.name,
    this.price,
    required this.imageUrls,
    required this.quantity,
    this.description,
    this.sizes = const [],
    this.selectedSize,
    this.imageBytes,  // ← добавлен параметр в конструктор
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double? parsedPrice;

    final priceStr = json['price'];
    if (priceStr != null) {
      parsedPrice = double.tryParse(priceStr.toString());
    }

    final List<String> imageUrls = [];

    if (json['images'] != null && json['images'] is List) {
      for (final imgItem in json['images']) {
        if (imgItem is Map<String, dynamic> && imgItem['image_url'] != null) {
          imageUrls.add(imgItem['image_url']);
        }
      }
    }

    if (imageUrls.isEmpty && json['first_image_url'] != null) {
      imageUrls.add(json['first_image_url']);
    }

    List<SizeInfo> sizes = [];
    if (json['sizes'] != null && json['sizes'] is List) {
      for (final item in json['sizes']) {
        if (item is Map<String, dynamic> && item['size'] != null) {
          sizes.add(SizeInfo.fromJson(item));
        }
      }
    }

    return Product(
      id: json['external_id'] ?? json['id'].toString(),
      name: json['name'] ?? '',
      price: parsedPrice,
      imageUrls: imageUrls,
      description: json['description'] ?? '',
      quantity: 1,
      sizes: sizes,
    );
  }
}

class SizeInfo {
  final String size;
  final int stock;

  SizeInfo({required this.size, required this.stock});

  factory SizeInfo.fromJson(Map<String, dynamic> json) {
    return SizeInfo(
      size: json['size'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }
}
