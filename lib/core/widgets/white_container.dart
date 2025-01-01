import 'package:flutter/material.dart';

import '../utils/constants.dart';

class WhiteBorderRadiusContainer extends StatelessWidget {
  const WhiteBorderRadiusContainer({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.child,
    this.topPadding = 20,
  });

  final double screenWidth;
  final double screenHeight;
  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        color: secondryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.09),
          topRight: Radius.circular(screenWidth * 0.09),
        ),
      ),
      child: child,
    );
  }
}
