import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MyButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  const MyButton({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: screenHeight * 0.072,
        width: screenWidth * 0.84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              appColor1,
              appColor2,
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: const TextStyle(
                  color: myLightGrey,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: secondryColor,
                size: 35,
              ),
            ),
          ],
        ),
      ),
    );

    /*   return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      width: double.infinity,
      height: screenWidth * 0.18,
      decoration: BoxDecoration(
        color: myPurple,
        borderRadius: BorderRadius.circular(screenWidth * 0.1), // نسبة من عرض الشاشة لتحديد الزوايا
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            color: myLightGrey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
   */
  }
}
