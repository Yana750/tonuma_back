import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TonumaLogo extends StatelessWidget {
  final Color textColor;
  final Color backgroundColor;
  final double fontSize;
  final double letterSpacing;
  final double borderRadius;
  final EdgeInsets padding;
  final Color borderColor;
  final double borderWidth;

  const TonumaLogo({
    super.key,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.orangeAccent,
    this.fontSize = 32,
    this.letterSpacing = 6.0,
    this.borderRadius = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
        child: Stack(
          children: [
            Text(
              'TONUMA',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = textColor,
              ),
            ),
            Text(
              'TONUMA',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        )
    );
  }
}
