import 'package:flutter/material.dart';

import '../../../widgets/constants.dart';

class MySearchBAR extends StatelessWidget {
  const MySearchBAR({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем ширину экрана устройства
    final screenWidth = MediaQuery.of(context).size.width;

    // Рассчитываем динамические размеры
    final containerHeight = screenWidth * 0.12; // Высота 14% от ширины экрана
    final borderRadius = screenWidth * 0.05; // Радиус скругления 8% от ширины экрана
    final horizontalPadding = screenWidth * 0.035; // Горизонтальный отступ 6% от ширины
    final iconSize = screenWidth * 0.07; // Размер иконок 7% от ширины экрана
    final dividerWidth = screenWidth * 0.0003; // Ширина разделителя

    return Container(
      height: containerHeight, // Адаптивная высота
      width: double.infinity,
      decoration: BoxDecoration(
        color: kcontentColor,
        borderRadius: BorderRadius.circular(borderRadius), // Адаптивный радиус
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, // Адаптивный горизонтальный отступ
        vertical: containerHeight * 0.1, // Вертикальный отступ как 10% от высоты
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey, size: iconSize), // Адаптивный размер иконки
          SizedBox(width: screenWidth * 0.02), // Ширина отступа 2% от ширины экрана
          Flexible(
            flex: 4,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Поиск...",
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            height: containerHeight * 0.3, // Высота разделителя как 50% от высоты контейнера
            width: dividerWidth, // Адаптивная ширина разделителя
            color: Colors.grey,
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(Icons.tune, color: Colors.grey, size: iconSize), // Адаптивный размер иконки
          // ),
        ],
      ),
    );
  }
}