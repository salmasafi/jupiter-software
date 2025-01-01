// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/styles.dart';
import '../../../core/widgets/build_appbar_method.dart';
import '../../../core/widgets/mybutton.dart';
import '../../../core/widgets/mytextfield.dart';
import '../../login/logic/models/user_model.dart';

class PaymentEditingScreen extends StatefulWidget {
  final UserModel userModel;

  const PaymentEditingScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<PaymentEditingScreen> createState() => _PasswordEditingScreenState();
}

class _PasswordEditingScreenState extends State<PaymentEditingScreen> {
  TextEditingController instapayLinkController = TextEditingController();
  TextEditingController cashWalletController = TextEditingController();
  TextEditingController cardHolderNameController = TextEditingController();

  editPaymentInfo() async {
    bool result = await APiService().changePaymentInfo(
      userModel: widget.userModel,
      instapayLink: instapayLinkController.text,
      cashWallet: cashWalletController.text,
      cardHolderName: cardHolderNameController.text,
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'PaymentInfo have changed successfully',
          ),
        ),
      );
      widget.userModel.instapayLink = instapayLinkController.text;
      widget.userModel.cashWallet = cashWalletController.text;
      widget.userModel.cardHolderName = cardHolderNameController.text;
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'There\'s an error, Please try again',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    instapayLinkController.text = widget.userModel.instapayLink;
    cashWalletController.text = widget.userModel.cashWallet;
    cardHolderNameController.text = widget.userModel.cardHolderName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.02,
          ),
          children: [
            SizedBox(height: screenHeight * 0.1),
            Center(
              child: Text(
                'Edit payment information',
                style: Styles.style22,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            MyTextField(
              controller: instapayLinkController,
              fieldType: 'Text',
              text: 'Instapay username / CardNumber',
            ),
            MyTextField(
              controller: cashWalletController,
              fieldType: 'Text',
              text: 'Cash wallet',
            ),
            MyTextField(
              controller: cardHolderNameController,
              fieldType: 'Text',
              text: 'Card Holder Name',
            ),
            SizedBox(height: screenHeight * 0.03),
            MyButton(
              title: 'SUBMIT',
              onPressed: () {
                if (instapayLinkController.text != '' &&
                    cashWalletController.text != '' &&
                    cardHolderNameController.text != '') {
                  editPaymentInfo();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Payment information can not be empty',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
