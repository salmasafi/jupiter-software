import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/variables.dart';
import '../../../../core/widgets/build_appbar_method.dart';
import '../widgets/my_drawer.dart';
import '../../../login/logic/models/user_model.dart';

/* class HomeScreenBuilder extends StatefulWidget {
  final String id;
  const HomeScreenBuilder({
    super.key,
    required this.id,
  });

  @override
  State<HomeScreenBuilder> createState() => _HomeScreenBuilderState();
}

class _HomeScreenBuilderState extends State<HomeScreenBuilder> {
  Future<UserModel> getUserModel() async {
    return await APiService().getUserById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: getUserModel(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const MyErrorWidget();
        } else if (snapshot.hasData) {
          thisUserId = snapshot.data!.id;
          return HomeScreen(
            userModel: snapshot.data!,
          );
        } else {
          return const MyLoadingWidget();
        }
      },
    );
  }
}
 */
class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  const HomeScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  setId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', widget.userModel.id);
  }

  setEmployeeDoc() async {
    DocumentReference employeeDoc =
        FirebaseApi.getEmployeeDoc(id: widget.userModel.id);

    DocumentSnapshot employeeSnapshot =
        await FirebaseApi.getEmployeeSnapshot(id: widget.userModel.id);

    if (!employeeSnapshot.exists) {
      await employeeDoc.set({
        'name': widget.userModel.name,
        'fCMToken': fCMToken,
        'rate': {
          'totalRate': 0,
          'daysRating': 0,
        }
      });
    } else {
      fCMToken = await FirebaseMessaging.instance.getToken();
        await employeeDoc.update({
        'fCMToken': fCMToken,
      });
      }
    
  }

  checkBranch() {
    switch (widget.userModel.branch) {
      case 'Asafra':
      case 'asafra':
        employeesDoc = 'AsafraEmployees';
        Branch = 'Asafra';
        break;
      default:
        employeesDoc = 'Employees';
    }
  }

  @override
  void initState() {
    setId();
    checkBranch();
    setEmployeeDoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    thisUserId = widget.userModel.id;
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'WELCOME',
              style: Styles.style42,
            ),
            Text(
              widget.userModel.name,
              style: Styles.style28,
            ),
          ],
        ),
      ),
      drawer: MyDrawer(
        userModel: widget.userModel,
      ),
    );
  }
}
