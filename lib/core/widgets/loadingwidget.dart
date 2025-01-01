import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MyLoadingWidget extends StatelessWidget {
  const MyLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: buildAppBar(),
      backgroundColor: Colors.white,
      body: const Center(
        child: CircularProgressIndicator(
          color: myPurple,
        ),
      ),
    );
  }
}
