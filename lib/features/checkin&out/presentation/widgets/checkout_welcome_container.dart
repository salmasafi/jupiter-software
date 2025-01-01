import 'package:flutter/material.dart';
import 'package:jupiter_academy/features/login/logic/models/user_model.dart';
import '../../../../core/utils/styles.dart';

class CheckOutWelcomeContainer extends StatelessWidget {
  const CheckOutWelcomeContainer({
    super.key,
    required this.screenHeight,
    required this.userModel,
  });

  final double screenHeight;
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(top: screenHeight * 0.02),
          child: Text(
            'Welcome!',
            style: Styles.style25,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            userModel.name,
            style: Styles.style25,
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Today\'s Status',
            style: Styles.style25,
          ),
        ),
      ],
    );
  }
}
