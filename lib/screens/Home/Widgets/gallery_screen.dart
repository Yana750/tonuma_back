import 'package:flutter/material.dart';

import '../../../services/image_service.dart';
import 'image_slider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<String>> _imageUrls;

  @override
  void initState() {
    super.initState();
    _imageUrls = ImageService().fetchImageUrls();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _imageUrls,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ImageSlider(imageUrls: snapshot.data!),
          );
        } else {
          return const Center(child: Text('Нет изображений'));
        }
      },
    );
  }
}
