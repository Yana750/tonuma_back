import 'package:flutter/material.dart';
import 'dart:typed_data';

class FullScreenImage extends StatelessWidget {
  final Uint8List imageBytes;
  final String tag;

  const FullScreenImage({super.key, required this.imageBytes, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: tag,
            child: Image.memory(imageBytes),
          ),
        ),
      ),
    );
  }
}
