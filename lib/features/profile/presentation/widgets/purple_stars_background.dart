import 'package:flutter/material.dart';

class PurpleStarsBackground extends StatelessWidget {
  const PurpleStarsBackground({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Image.asset(
        'assets/images/purple_backgroung_with_stars.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
