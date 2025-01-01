import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/build_appbar_method.dart';
import '../../../../core/widgets/mybutton.dart';
import '../../../../core/widgets/mytextfield.dart';
import '../../../login/logic/models/user_model.dart';

class EmployeeData extends StatefulWidget {
  final UserModel userModel;
  const EmployeeData({super.key, required this.userModel});

  @override
  State<EmployeeData> createState() => _EmployeeDataState();
}

class _EmployeeDataState extends State<EmployeeData> {
  TextEditingController controller = TextEditingController();

  Future<void> storeSalary(String id, int salary) async {
    try {
      /* SalaryService salaryService = SalaryService();
      String encryptedSalary = await salaryService.encryptSalary(salary);

      // تأكد من أن النص المشفر لم يتغير قبل التخزين
      print('Before storing: $encryptedSalary'); */

      DocumentReference employeeDoc = FirebaseApi.getEmployeeDoc(id: id);

      await employeeDoc.update({
        'salary': salary,
      });

      /* // استرجاع النص المشفر للتحقق
      DocumentSnapshot employeeSnapshot = await employeeDoc.get();
      String storedEncryptedSalary = employeeSnapshot['salary'];
      print('After storing: $storedEncryptedSalary');

      if (encryptedSalary == storedEncryptedSalary) {
        print('The encrypted salary has been stored correctly.');
      } else {
        print('The encrypted salary has been altered during storage.');
      } */
    } catch (e) {
      print('Error storing salary: $e');
    }
  }

  Future<void> getSalary(String id) async {
    try {
      DocumentSnapshot employeeSnapshot =
          await FirebaseApi.getEmployeeSnapshot(id: id);

      if (employeeSnapshot.exists &&
          (employeeSnapshot.data() as Map<String, dynamic>)
              .containsKey('salary')) {
        String encryptedSalary = '${employeeSnapshot['salary']}';
        controller.text = encryptedSalary;
        /* print('Retrieved encrypted salary: $encryptedSalary');

        final service = SalaryService();
        // فك تشفير النص
        final decrypted = await service.decryptSalary(encryptedSalary);
        print('Decrypted: $decrypted'); */
      }
    } catch (e) {
      print('Error retrieving salary: $e');
    }
  }

  @override
  void initState() {
    getSalary(widget.userModel.id);
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
                'Edit ${widget.userModel.name}\'s salary',
                style: Styles.style22,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            MyTextField(
              controller: controller,
              fieldType: 'numbers',
              text: '${widget.userModel.name}\'s salary',
            ),
            SizedBox(height: screenHeight * 0.03),
            MyButton(
              title: 'SUBMIT',
              onPressed: () {
                if (controller.text != '') {
                  try {
                    storeSalary(
                      widget.userModel.id,
                      int.parse(controller.text),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Salary has been stored successfully',
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
                        'Salary can not be empty',
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
