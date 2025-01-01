import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jupiter_academy/core/services/api_service.dart';
import 'package:jupiter_academy/core/services/firebase_api.dart';
import 'package:jupiter_academy/core/services/location_service.dart';
import 'package:jupiter_academy/features/branches/logic/models/branch_model.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/build_appbar_method.dart';
import '../../../../core/widgets/mybutton.dart';
import '../../../../core/widgets/mytextfield.dart';

class EditBranch extends StatefulWidget {
  final BranchModel branchModel;
  const EditBranch({super.key, required this.branchModel});

  @override
  State<EditBranch> createState() => _EditBranchState();
}

class _EditBranchState extends State<EditBranch> {
  TextEditingController branchNameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();

  @override
  void initState() {
    branchNameController.text = widget.branchModel.branch_Name;
    locationController.text = widget.branchModel.location;
    cityController.text = widget.branchModel.city;
    phoneController.text = widget.branchModel.phone;
    whatsappController.text = widget.branchModel.whatsApp;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Edit ${widget.branchModel.branch_Name} branch details',
                  style: Styles.style20,
                ),
                const SizedBox(
                  height: 20,
                ),
                MyTextField(
                  controller: branchNameController,
                  fieldType: 'text',
                  text: 'Branch name',
                ),
                MyTextField(
                  controller: locationController,
                  fieldType: 'text',
                  text: 'Location',
                  hintText: 'add a Google map link',
                ),
                MyTextField(
                  controller: cityController,
                  fieldType: 'text',
                  text: 'city',
                ),
                MyTextField(
                  controller: phoneController,
                  fieldType: 'text',
                  text: 'phone',
                ),
                MyTextField(
                  controller: whatsappController,
                  fieldType: 'text',
                  text: 'whatsapp',
                ),
                const SizedBox(
                  height: 20,
                ),
                MyButton(
                  title: 'UPDATE BRANCH',
                  onPressed: () async {
                    Map<String, double> coordinatesFromLink =
                        await LocationService.extractCoordinatesFromUrl(
                      locationController.text,
                    );

                    String address =
                        await LocationService.getAddressFromCoordinates(
                      coordinatesFromLink['latitude'] ?? 0,
                      coordinatesFromLink['longitude'] ?? 0,
                    );

                    DocumentReference branchDoc = FirebaseApi.getBranchDoc(
                        branch: widget.branchModel.branch_Name);
                    DocumentSnapshot branchSnapshot = await branchDoc.get();

                    if (branchSnapshot.exists) {
                      branchDoc.update({
                        'location': {
                          'latitude': coordinatesFromLink['latitude'] ?? 0,
                          'longitude': coordinatesFromLink['longitude'] ?? 0,
                        }
                      });
                    } else {
                      print(
                          'There was an error updating coordinates in firebase');
                    }

                    bool result = await APiService().editABranch(
                      BranchModel(
                        branch_Id: widget.branchModel.branch_Id,
                        branch_Name: branchNameController.text,
                        location: address,
                        city: cityController.text,
                        phone: phoneController.text,
                        whatsApp: whatsappController.text,
                        employeesNo: widget.branchModel.employeesNo,
                        studentNo: widget.branchModel.studentNo,
                      ),
                    );

                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Branch details have updated successfully',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'There was an error, branch details didn\'t been updated',
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
    );
  }
}
