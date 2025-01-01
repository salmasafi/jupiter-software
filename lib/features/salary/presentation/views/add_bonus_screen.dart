import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/firebase_api.dart';
import '../../../../../core/utils/styles.dart';
import '../../../../../core/widgets/build_appbar_method.dart';
import '../../../../../core/widgets/mybutton.dart';
import '../../../../../core/widgets/mytextfield.dart';
import '../../../login/logic/models/user_model.dart';

class AddBonusScreen extends StatefulWidget {
  final UserModel userModel;
  final String month;
  const AddBonusScreen({super.key, required this.userModel, required this.month});

  @override
  State<AddBonusScreen> createState() => _AddBonusScreenState();
}

class _AddBonusScreenState extends State<AddBonusScreen> {
  TextEditingController controller = TextEditingController();
  bool workedInCurrentMonth = false;

  Future<void> storeBonus(String id, int bonus) async {
    try {
      DocumentReference employeeDoc =
          FirebaseApi.getEmployeeDocForSpecificMonth(id: id, month: widget.month);

      await employeeDoc.update({
        'bonus': bonus,
      });
    } catch (e) {
      print('Error storing bonus: $e');
    }
  }

  Future<void> getBonus(String id) async {
    try {
      DocumentSnapshot employeeSnapshot =
          await FirebaseApi.getEmployeeSnapshotForSpecificMonth(
              id: id, month: widget.month);

      if (employeeSnapshot.exists &&
          (employeeSnapshot.data() as Map<String, dynamic>)
              .containsKey('bonus')) {
        String bonus = '${employeeSnapshot['bonus']}';
        controller.text = bonus.toString();
      } else {
        controller.text = '0';
      }
    } catch (e) {
      print('Error retrieving bonus: $e');
    }
  }

  Future<void> initScreen() async {
    await getBonus(widget.userModel.id);
  }

  @override
  void initState() {
    initScreen();
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
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          children: [
            SizedBox(height: screenHeight * 0.1),
            Center(
              child: Text(
                'Add bonus to ${widget.userModel.name} for ${widget.month}',
                style: Styles.style22,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            MyTextField(
              controller: controller,
              fieldType: 'numbers',
              text: '${widget.userModel.name}\'s bonus',
            ),
            SizedBox(height: screenHeight * 0.03),
            MyButton(
              title: 'SUBMIT',
              onPressed: () {
                if (controller.text != '') {
                  try {
                    storeBonus(
                      widget.userModel.id,
                      int.parse(controller.text),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bonus has been stored successfully',
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'There was an error, try again',
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Bonus can not be empty',
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
