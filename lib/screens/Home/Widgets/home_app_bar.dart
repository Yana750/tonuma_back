import 'package:flutter/material.dart';

import '../../../widgets/constants.dart';


class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем ширину экрана устройства
    final screenWidth = MediaQuery.of(context).size.width;

    // Рассчитываем отступы и размеры на основе ширины экрана
    final padding = screenWidth * 0.03; // 4% от ширины экрана
    final iconSize = screenWidth * 0.055; // 6% от ширины экрана

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: kcontentColor,
            padding: EdgeInsets.all(padding), // Динамические отступы
          ),
          onPressed: () {},
          icon: Image.asset(
            "images/icon.png",
            height: iconSize, // Динамический размер иконки
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: kcontentColor,
            padding: EdgeInsets.all(padding), // Динамические отступы
          ),
          onPressed: () {},
          iconSize: iconSize, // Динамический размер иконки
          icon: Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }
}