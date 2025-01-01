// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  String fieldType;
  final String text;
  final IconData? icon;
  bool? isObsecure;
  Color? labelColor;
  bool readOnly;
  void Function(String)? onChanged;
  TextEditingController? controller;
  String? hintText;
  MyTextField({
    super.key,
    this.fieldType = 'text',
    required this.text,
    this.icon,
    this.isObsecure,
    this.onChanged,
    this.controller,
    this.hintText,
    this.labelColor,
    this.readOnly = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        //vertical: screenHeight * 0.02,
      ),
      //padding: EdgeInsets.only(left: screenWidth * 0.03),
      height: screenHeight * 0.085,
      width: double.infinity,

      child: TextField(
        readOnly: widget.readOnly,
        controller: widget.controller,
        keyboardType:
            widget.fieldType == 'numbers' ? TextInputType.number : null,
        style: TextStyle(
          fontSize: screenHeight * 0.025,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.text,
          labelStyle: TextStyle(
            color: widget.labelColor ?? Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: screenHeight * 0.018,
          ),
          /* prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  size: screenHeight * 0.035,
                  color: myPurple,
                )
              : null, */
          suffixIcon:
              (widget.fieldType == 'Password' || widget.fieldType == 'password')
                  ? IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        setState(() {
                          if (widget.isObsecure == true) {
                            widget.isObsecure = false;
                          } else {
                            widget.isObsecure = true;
                          }
                        });
                      },
                    )
                  : null,
          //border: InputBorder.none,
          //border: UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        obscureText: widget.isObsecure ?? false,
        onChanged: widget.onChanged,
      ),
    );
  }
}
