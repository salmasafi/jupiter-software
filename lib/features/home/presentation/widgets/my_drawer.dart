import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupiter_academy/features/checkin&out/presentation/views/home_shift.dart';
import 'package:jupiter_academy/features/requests/presentation/views/requests_screen.dart';
import 'package:jupiter_academy/features/unrated_checkouts/presentation/views/unrated_checkouts_screen.dart';
import 'package:jupiter_academy/features/salary/presentation/views/salary_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/cubit/jupiter_cubit.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/widgets/stars_widget.dart';
import '../../../branches/presentation/views/branches_screen.dart';
import '../../../employees/logic/employees_screen_builder.dart';
import '../../../attendance/logic/attendance_screen_builder.dart';
import '../../../batches/presentation/views/batches_screen.dart';
import '../../../checkin&out/presentation/views/checkinout_screen.dart';
import '../../../login/logic/models/user_model.dart';
import '../../../login/presentation/views/loginscreen.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/styles.dart';
import '../../../profile/presentation/views/profilescreen.dart';
import '../../../salary/presentation/views/total_salary_screen.dart';

class MyDrawer extends StatefulWidget {
  final UserModel userModel;
  const MyDrawer({
    super.key,
    required this.userModel,
  });

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  double _totalRating = 0.0;
  int _rating = 0;
  int _daysRating = 0;

  Future<void> _fetchRating() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseApi.getEmployeeSnapshot(id: widget.userModel.id);

      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        _rating = data['rate']['totalRate'];
        _daysRating = data['rate']['daysRating'];

        if (_daysRating != 0) {
          setState(() {
            _totalRating = (_rating / _daysRating) / 2;
          });
        } else {
          setState(() {
            _totalRating = 0.0;
          });
        }
      } else {
        print('error while fetching data');
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: myPurple,
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocBuilder<JupiterCubit, JupiterState>(
                    builder: (context, state) {
                      String imageUrl;
                      if (state is ImageChangedState &&
                          state.imageUrl != null) {
                        imageUrl = state.imageUrl!;
                      } else {
                        imageUrl = widget.userModel.profileImagePath != ''
                            ? widget.userModel.profileImagePath
                            : 'https://jupiter-academy.org/assets/images/Jupiter%20Outlined.png';
                      }
                      return CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(imageUrl),
                      );
                    },
                  ),
                  //const SizedBox(height: 5),
                  Text(
                    widget.userModel.name,
                    style: Styles.style21,
                  ),
                  (widget.userModel.role != 'Manager' ||
                          widget.userModel.role != 'manager')
                      ? Builder(
                          builder: (context) {
                            _fetchRating();

                            return StarsWidget(initialRating: _totalRating);
                          },
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          (widget.userModel.role == 'Instructor' ||
                  widget.userModel.role == 'instructor' ||
                  widget.userModel.role == 'Admin' ||
                  widget.userModel.role == 'admin' ||
                  widget.userModel.role == 'Manager' ||
                  widget.userModel.role == 'manager')
              ? ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Check-in & Out'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckInOutScreen(
                          userModel: widget.userModel,
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          // (widget.userModel.userName == 'SalmaSafi' ||
          //     widget.userModel.userName == 'ahmad' ||
          //     widget.userModel.userName == 'Mohamed_Elsayed' ||
          //     widget.userModel.userName == 'OmarEslam' ||
          //     widget.userModel.role == 'Manager' ||
          //     widget.userModel.role == 'manager')
          //     ?

          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Home Shift'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeShiftScreen(
                    userModel: widget.userModel,
                  ),
                ),
              );
            },
          ),
             // : const SizedBox(),
          (widget.userModel.role == 'Instructor' ||
                  widget.userModel.role == 'instructor' ||
                  widget.userModel.role == 'Admin' ||
                  widget.userModel.role == 'admin' ||
                  widget.userModel.role == 'Manager' ||
                  widget.userModel.role == 'manager')
              ? ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Attendance'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceScreenBuilder(
                          id: widget.userModel.id,
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userModel: widget.userModel,
                  ),
                ),
              );
            },
          ),
          (widget.userModel.role == 'Instructor' ||
                  widget.userModel.role == 'instructor')
              ? ListTile(
                  leading: const Icon(Icons.home_work),
                  title: const Text('My Batches'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BatchesScrennBuilder(
                          userModel: widget.userModel,
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          (widget.userModel.role == 'Manager' ||
                  widget.userModel.role == 'manager' ||
                  widget.userModel.userName == 'SalmaSafi')
              ? ListTile(
                  leading: const Icon(Icons.home_work),
                  title: const Text('Branches'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BranchesScreen(),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          (widget.userModel.role == 'Manager' ||
                  widget.userModel.role == 'manager' ||
                  widget.userModel.userName == 'SalmaSafi')
              ? ListTile(
                  leading: const Icon(Icons.manage_accounts),
                  title: const Text('Employees'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EmployeeBranchScreenBuilder(),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Salary'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  (widget.userModel.role == 'Manager' ||
                  widget.userModel.role == 'manager' ||
                    widget.userModel.userName == 'SalmaSafi')
              ?
                  const TotalSalaryScreen()
              : SalaryScreen(
                    userModel: widget.userModel,
                  ),
                ),
              );
            },
          ),
           (widget.userModel.role == 'Manager' ||
                  widget.userModel.role == 'manager' ||
                  widget.userModel.userName == 'SalmaSafi')
              ? ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Unrated check-outs'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UnratedCheckoutsScreen()
                ),
              );
            },
          ): const SizedBox(),

          (widget.userModel.role == 'Manager' ||
                  widget.userModel.role == 'manager' ||
                  widget.userModel.userName == 'SalmaSafi')
              ? ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Requests'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestsScreen()
                ),
              );
            },
          ): const SizedBox(),

           /*  ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () async {
              final service = SalaryService();

             
              
                String encryptedSalary = 'rKMebZtUGIuQTR/OpZUKKQ==';

                // فك تشفير النص
                final decrypted = await service.decryptSalary(encryptedSalary);
                print('Decrypted: $decrypted');
              
            },
          ), */
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
