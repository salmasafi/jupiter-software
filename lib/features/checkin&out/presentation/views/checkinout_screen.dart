// ignore_for_file: avoid_print, body_might_complete_normally_nullable
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_api.dart';
import '../../../../core/utils/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/build_appbar_method.dart';
import '../../../login/logic/models/user_model.dart';
import '../../logic/calculatetime_method.dart';
import '../widgets/checkinout_column.dart';
import '../widgets/checkout_textfield.dart';
import '../widgets/checkout_welcome_container.dart';
import '../widgets/good_job_container.dart';
import '../widgets/my_alert_dialog.dart';
import '../widgets/myslidebar.dart';
import '../widgets/timenow_container.dart';
import '../widgets/total_work_time_container.dart';

class CheckInOutScreen extends StatefulWidget {
  final UserModel userModel;
  const CheckInOutScreen({super.key, required this.userModel});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  //File? image;
  //final _picker = ImagePicker();

  bool showSpinner = true;
  bool isCheckOutDone = false;
  bool showTextField = false;

  String checkIn = '--/--';
  String checkOut = '--/--';

  String checkOutDetails = '.....';
  String checkOutDetailsTemp = '......';
  Map<String, dynamic> totalWorkTime = {};

  String? token;
  String? token2;

  TextEditingController _controller = TextEditingController();
  final GlobalKey<SlideActionState> key = GlobalKey();

  String isWithinCompanyPremises = 'pending';
  LocationService locationService = LocationService();

  @override
  void initState() {
    _getCheckInOuts();
    _getManagerToken();
    _getMyToken();
    _loadSavedText();
    _determineLocation();
    super.initState();
  }

  @override
  void dispose() {
    locationService.stopTracking();
    super.dispose();
  }

  _determineLocation() async {
    await locationService.determinePosition(widget.userModel.id,
        (String isWithin) {
      print('Callback received: isWithinCompanyPremises = $isWithin');
      setState(() {
        isWithinCompanyPremises = isWithin;
      });
    });
  }

  _getCheckInOuts() async {
    try {
      DocumentSnapshot employeeSnapshot =
          await FirebaseApi.getEmployeeSnapshotForToday(
              id: widget.userModel.id);
      if (employeeSnapshot.exists) {
        if (employeeSnapshot['checkOutDetails'] == '......') {
          isCheckOutDone = false;
          showTextField = true;
        } else if (employeeSnapshot['checkOut'] == '--/--') {
          isCheckOutDone = false;
          showTextField = true;
        } else {
          isCheckOutDone = true;
          showTextField = false;
        }
        setState(() {
          checkIn = employeeSnapshot['checkIn'];
          checkOut = employeeSnapshot['checkOut'];
          totalWorkTime = employeeSnapshot['totalWorkTime'];
        });
        print(
            'Data fetched successfully: checkIn: $checkIn, checkOut: $checkOut, totalWorkTime: $totalWorkTime');

        showSpinner = false;
      } else {
        setState(() {
          checkIn = '--/--';
          checkOut = '--/--';
          totalWorkTime = {'hours': 0, 'minutes': 0};
          showSpinner = false;
        });
        print('Document does not exist.');
      }
    } catch (e) {
      checkIn = '--/--';
      checkOut = '--/--';
      totalWorkTime = {'hours': 0, 'minutes': 0};

      print('Error fetching data: $e');
      setState(() {});
    }
  }

  _getManagerToken() async {
    try {
      DocumentSnapshot managerDoc = await FirebaseApi.getManagerSnapshot();

      if (!managerDoc.exists) {
        throw Exception('Manager not found');
      }

      print('Manager data: ${managerDoc.data()}');

      Map<String, dynamic> managerData =
          managerDoc.data() as Map<String, dynamic>;

      if (managerData.containsKey('fCMToken')) {
        token = managerData['fCMToken'];
      }

      print('Fetching manager token done $token');
    } catch (e) {
      print('Error fetching manager token: $e');
    }
  }

  _getMyToken() async {
    try {
      DocumentSnapshot managerDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc('d666da61-11ed-48d2-bee7-f994d85e6be0')
          .get();

      if (!managerDoc.exists) {
        throw Exception('Manager not found');
      }

      print('Manager data: ${managerDoc.data()}');

      Map<String, dynamic> managerData =
          managerDoc.data() as Map<String, dynamic>;

      if (managerData.containsKey('fCMToken')) {
        token2 = managerData['fCMToken'];
      }

      print('token is $token2');

      print('Fetching manager token done');
    } catch (e) {
      print('Error fetching manager token: $e');
    }
  }

  Future<void> _loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final lastCheckOutDate =
        prefs.getString('checkOutDetailsDate${widget.userModel.id}');

    if (lastCheckOutDate == DateFormat('dd MMMM yyyy').format(DateTime.now())) {
      setState(() {
        _controller.text =
            prefs.getString('checkOutDetails${widget.userModel.id}') ?? '';

        if (_controller.text == '') {
          showTextField = true;
        } else {
          showTextField = false;
        }
      });
    } else {
      _deleteText();
    }
  }

  Future<void> _saveText(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkOutDetails${widget.userModel.id}', text);
    await prefs.setString('checkOutDetailsDate${widget.userModel.id}',
        DateFormat('dd MMMM yyyy').format(DateTime.now()));
  }

  Future<void> _deleteText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('checkOutDetails${widget.userModel.id}');
    await prefs.remove('checkOutDetailsDate${widget.userModel.id}');
    setState(() {
      _controller.clear();
    });
  }

  Future<bool> _undoCheckIn() async {
    try {
      print('Trying to delete document and date');
      DocumentReference employeeDoc =
          FirebaseApi.getEmployeeDocForToday(id: widget.userModel.id);

      DocumentSnapshot employeeSnapshot = await employeeDoc.get();

      if (employeeSnapshot.exists) {
        await employeeDoc.delete();
        print('Document successfully deleted!');
        setState(() {
          checkIn = '--/--';
          checkOut = '--/--';
          showTextField = false;
          checkOutDetails = '......';
        });
        return true;
      } else {
        print('Document does not exist.');
        return false;
      }
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  Future<bool> _undoCheckOut() async {
    try {
      DocumentReference employeeDoc =
          FirebaseApi.getEmployeeDocForToday(id: widget.userModel.id);
      DocumentSnapshot employeeSnapshot = await employeeDoc.get();

      if (employeeSnapshot.exists) {
        await employeeDoc.update({
          'checkOut': '--/--',
          'totalWorkTime': {
            'hours': 0,
            'minutes': 0,
          }
        });

        await _loadSavedText();
        print('Checkout successfully updated!');
        setState(() {
          checkOut = '--/--';
          isCheckOutDone = false;
          showTextField = true;
        });
        return true;
      } else {
        print('Checkout updating failed.');
        return false;
      }
    } catch (e) {
      print('Error updating checkout: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    DocumentReference employeeDoc =
        FirebaseApi.getEmployeeDocForToday(id: widget.userModel.id);

    return Scaffold(
      appBar: buildAppBar(),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              CheckOutWelcomeContainer(
                screenHeight: screenHeight,
                userModel: widget.userModel,
              ),
              Container(
                height: screenHeight * 0.2,
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.04),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: myPurple,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => MyAlertDialog(
                              title: 'Undo Check-In',
                              body: 'Do you want to undo your check-in?',
                              onYes: () async {
                                bool result = await _undoCheckIn();
                                if (result == true) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          );
                        },
                        child: CheckInOutColumn(
                          title: 'Check In',
                          check: checkIn,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => MyAlertDialog(
                              title: 'Undo Check-Out',
                              body: 'Do you want to undo your check-out?',
                              onYes: () async {
                                bool result = await _undoCheckOut();
                                if (result == true) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          );
                        },
                        child: CheckInOutColumn(
                          title: 'Check Out',
                          check: checkOut,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TimeNowContainer(),
              isWithinCompanyPremises == 'true'
                  ? SizedBox(
                      child: checkIn == '--/--' || checkOut == '--/--'
                          ? MySlideBar(
                              screenHeight: screenHeight,
                              checkIn: checkIn,
                              myKey: key,
                              onSubmit: () async {
                                key.currentState!.reset();
                                DocumentSnapshot employeeSnapshot =
                                    await employeeDoc.get();

                                if (employeeSnapshot.exists) {
                                  if (_controller.text == '') {
                                    showDialog(
                                      context: context,
                                      builder: (context) => MyAlertDialog(
                                        title: 'No check-out details',
                                        body:
                                            'You didn\'t write any check-out details, Write it first and then you can check-out',
                                        onYes: () async {
                                          Navigator.of(context).pop();
                                        },
                                        yesAndNo: false,
                                      ),
                                    );
                                  } else {
                                    checkOut = DateFormat('hh:mm a')
                                        .format(DateTime.now());

                                    totalWorkTime = calculateTimeDifference(
                                      startTime: checkIn,
                                      endTime: checkOut,
                                    );

                                    checkOutDetails =
                                        (_controller.text != '......' ||
                                                _controller.text != '')
                                            ? _controller.text
                                            : '......';

                                    await employeeDoc.update({
                                      'checkOut': checkOut,
                                      'checkOutDetails': checkOutDetails,
                                      'totalWorkTime': totalWorkTime,
                                    });

                                    NotificationApi().sendNotification(
                                      body:
                                          '${widget.userModel.name} has checked out at ${DateFormat('hh:mm a').format(DateTime.now())}!',
                                      title: 'New on-site check-out!',
                                      token: token2!,
                                      page: 'attendance',
                                      employeeId: widget.userModel.id,
                                      //Salma Safi
                                    );

                                    NotificationApi().sendNotification(
                                      body:
                                          '${widget.userModel.name} has checked out at ${DateFormat('hh:mm a').format(DateTime.now())}!',
                                      title: 'New on-site check-out!',
                                      token: token!,
                                      page: 'attendance',
                                      employeeId: widget.userModel.id,
                                      //Amira Gomaa
                                    );

                                    checkOutDetails = '......';
                                    isCheckOutDone = true;

                                    setState(() {});
                                  }
                                } else {
                                  DocumentReference employeeDocument =
                                      FirebaseApi.getEmployeeDocForThisMonth(
                                    id: widget.userModel.id,
                                  );

                                  await employeeDocument.set({
                                    'temp': 'temp',
                                  });

                                  await employeeDoc.set({
                                    'checkIn': DateFormat('hh:mm a')
                                        .format(DateTime.now()),
                                    'checkOut': '--/--',
                                    'day': DateFormat('EEEE')
                                        .format(DateTime.now()),
                                    'totalWorkTime': {'hours': 0, 'minutes': 0},
                                    'checkOutDetails': '......',
                                    'rate': -1,
                                    'shiftType': 'onSite',
                                  });

                                  NotificationApi().sendNotification(
                                    body:
                                        '${widget.userModel.name} has checked in at ${DateFormat('hh:mm a').format(DateTime.now())}!',
                                    title: 'New on-site check-in!',
                                    token: token2!,
                                    page: 'attendance',
                                    employeeId: widget.userModel.id,
                                    //Salma Safi
                                  );

                                  NotificationApi().sendNotification(
                                    body:
                                        '${widget.userModel.name} has checked in at ${DateFormat('hh:mm a').format(DateTime.now())}!',
                                    title: 'New on-site check-in!',
                                    token: token!,
                                    page: 'attendance',
                                    employeeId: widget.userModel.id,
                                    //Amira Gomaa
                                  );

                                  setState(() {
                                    showTextField = true;
                                    checkOutDetails = '......';
                                    checkIn = DateFormat('hh:mm a')
                                        .format(DateTime.now());
                                  });
                                }
                              },
                            )
                          : TotalWorkTimeContainer(
                              totalWorkTime: totalWorkTime,
                            ),
                    )
                  : isWithinCompanyPremises == 'pending'
                      ? const CircularProgressIndicator()
                      : checkOut == '--/--'
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'You are outside company premises.',
                                style: Styles.style18BlackBold,
                              ),
                            )
                          : TotalWorkTimeContainer(
                              totalWorkTime: totalWorkTime,
                            ),
              isCheckOutDone == false && showTextField == true
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        CheckOutTextField(
                          controller: _controller,
                          onChanged: (value) {
                            checkOutDetailsTemp = value;
                            _saveText(_controller.text);
                          },
                        ),
                        /* const SizedBox(height: 10,),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    width: screenWidth * 0.4,
                                    height: screenHeight * 0.07,
                                    child: const Center(
                                      child: Text(
                                        'Pick an image',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                               */
                      ],
                    )
                  : checkOut != '--/--'
                      ? const GoodJobContainer()
                      : const SizedBox(),
              /* TextButton(
                onPressed: () async {
                  String googleMapsUrl =
                      'https://www.google.com/maps/place/Jupiter+academy,+%D8%A8%D8%B9%D8%AF+%D9%83%D8%B1%D9%85+%D8%A7%D9%84%D8%B4%D8%A7%D9%85+%D9%88+%D9%83%D9%86%D8%A7%D9%81%D8%A9+%D9%88+%D8%A8%D8%B3%D8%A8%D9%88%D8%B3%D8%A9,+20+%D8%B4%D8%A7%D8%B1%D8%B9+%D8%B5%D8%AF%D9%8A%D9%82%D8%A7%D8%AA+%D8%A7%D9%84%D9%83%D8%AA%D8%A7%D8%A8+%D8%A7%D9%84%D9%85%D9%82%D8%AF%D8%B3,+%D9%85%D8%AA%D9%81%D8%B1%D8%B9+%D9%85%D9%86+%D8%B4%D8%A7%D8%B1%D8%B9+%D8%AC%D9%85%D8%A7%D9%84+%D8%B9%D8%A8%D8%AF+%D8%A7%D9%84%D9%86%D8%A7%D8%B5%D8%B1%E2%80%AD/@31.2724192,30.0047756,17z/data=!4m6!3m5!1s0x14f5d1a6762454b1:0xb3aae130f9f42bf4!8m2!3d31.2724192!4d30.0047756!16s%2Fg%2F11syzfcq45';

                  try {
                    final coordinates =
                        LocationService.extractCoordinatesFromUrl(
                            googleMapsUrl);
                    print(
                        'Latitude: ${coordinates['latitude']}, Longitude: ${coordinates['longitude']}');
                  } catch (e) {
                    print('Error extracting coordinates: $e');
                  }
                },
                child: Text('test'),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
