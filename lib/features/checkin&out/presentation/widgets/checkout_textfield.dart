import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

class CheckOutTextField extends StatelessWidget {
  const CheckOutTextField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      maxLines: 7,
      decoration: InputDecoration(
        hintText: 'Type your checkout here.......',
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: myPurple),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
