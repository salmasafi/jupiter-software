import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jupiter_academy/features/attendance/logic/attendance_screen_builder.dart';
import '../../../../../../core/services/firebase_api.dart';
import '../../../../../../core/utils/styles.dart';
import '../../../../../../core/widgets/build_appbar_method.dart';
import '../../../../../../core/widgets/mybutton.dart';
import '../../../checkin&out/presentation/widgets/checkout_textfield.dart';

class EditCheckOutWidget extends StatelessWidget {
  final String id;
  final String month;
  final Map<String, dynamic> dayCheckOut;

  const EditCheckOutWidget({
    super.key,
    required this.id,
    required this.month,
    required this.dayCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    String checkOutDetails = '......';

    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        controller.text = dayCheckOut['checkOutDetails'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: buildAppBar(),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Edit ${dayCheckOut['date']} - ${dayCheckOut['day']} checkOut details',
                        style: Styles.style20,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CheckOutTextField(
                        controller: controller,
                        onChanged: (value) {
                          checkOutDetails = value;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      MyButton(
                        title: 'UPDATE CHECKOUT',
                        onPressed: () async {
                          DocumentReference employeeDoc =
                              FirebaseApi.getEmployeeDocForSpecificDay(
                            id: id,
                            month: month,
                            date: dayCheckOut['date'],
                          );
                          DocumentSnapshot employeeSnapshot =
                              await employeeDoc.get();

                          if (employeeSnapshot.exists) {
                            await employeeDoc.update({
                              'checkOutDetails': checkOutDetails,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'CheckOut have changed successfully',
                                ),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttendanceScreenBuilder(
                                  id: id,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'There was an error, checkOut didn\'t been updated',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
