import 'dart:async';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const ImageSlider({
    super.key,
    required this.imageUrls,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startAutoSlide();
  }

  void startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentSlide < widget.imageUrls.length - 1) {
        _currentSlide++;
      } else {
        _currentSlide = 0;
      }
      _pageController.animateToPage(
        _currentSlide,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sliderHeight = screenHeight * 0.15;

    return Stack(
      children: [
        SizedBox(
          height: sliderHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentSlide = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ),
        // Индикаторы
        Positioned.fill(
          bottom: 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _currentSlide == index ? 16 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _currentSlide == index
                        ? Colors.black54
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}