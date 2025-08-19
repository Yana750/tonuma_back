import 'package:flutter/material.dart';

const kcontentColor = Color(0xffF5F5F5);
var kprimaryColor = Colors.orange[500];
const List<Color> grimaryColor = [
  Color(0xFFC02425),
  Color(0xfff0cb35)
];

Widget buildInput(
    String label,
    TextEditingController controller, {
      bool obscure = false,
      double fontSize = 14,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
        ),
        maxLines: 1,
      ),
      const SizedBox(height: 12),
    ],
  );
}

// Стиль кнопки
ButtonStyle buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );
}

Widget buildStyledInput(String label, TextEditingController controller, {bool obscure = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14, // <-- Тут меняешь размер шрифта
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          fontSize: 14, // <-- А это текст в самом поле
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}


// Универсальный виджет для создания радио кнопок
class RadioOption<T> extends StatelessWidget {
  final String title;
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged; // Accepting nullable onChanged

  const RadioOption({super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: kprimaryColor,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      tileColor:
      groupValue == value
          ? Colors.orange.withOpacity(0.08)
          : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}