
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import '../../../../core/utils/styles.dart';

class SubCheckOutContainer extends StatelessWidget {
  SubCheckOutContainer({
    super.key,
    required this.data,
    this.isCheckIn = true,
    this.height,
    this.width,
  });
  bool isCheckIn;
  final Map<String, dynamic> data;
  double? height;
  double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Text(
          isCheckIn
              ? 'Check-In: ${data['checkIn']}'
              : 'Check-Out: ${data['checkOut']}',
          style: Styles.style14Bold,
        ),
      ),
    );
  }
}

class SubContainer extends StatelessWidget {
  SubContainer(
      {super.key, required this.title, this.height, this.width, this.colors});

  final Widget title;
  double? height;
  double? width;
  List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: colors == null ? Colors.grey[200] : null,
        gradient: colors != null ? LinearGradient(colors: colors!) : null,
      ),
      child: Center(
        child: title,
      ),
    );
  }
}


