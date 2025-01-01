import 'package:flutter/material.dart';
import '../../../../core/utils/styles.dart';

// ignore: must_be_immutable
class DoneWidget extends StatelessWidget {
  DoneWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.isDataChanged,
    required this.onTap,
  });

  final double screenHeight;
  final double screenWidth;
  final VoidCallback onTap;

  bool isDataChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.037,
        width: screenWidth * 0.23,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: isDataChanged ? Colors.black : Colors.grey,
              ),
              const SizedBox(
                width: 3,
              ),
              Text(
                'DONE',
                style:
                    isDataChanged ? Styles.style14Bold : Styles.style14GreyBold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
