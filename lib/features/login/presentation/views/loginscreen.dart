// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/loadingwidget.dart';
import '../../../../core/widgets/mybutton.dart';
import '../../../../core/widgets/mytextfield.dart';
import '../../../../core/widgets/white_container.dart';
import '../../../home/presentation/views/homescreen.dart';
import '../../logic/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              'assets/images/purple_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: ListView(
              //padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              children: [
                SizedBox(
                  height: screenHeight * 0.33,
                  width: screenWidth,
                  child: Image.asset(
                    'assets/images/hi_there.png',
                    fit: BoxFit.none,
                  ),
                ),
                WhiteBorderRadiusContainer(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                        child: MyTextField(
                          fieldType: 'UserName',
                          text: 'Username',
                          icon: Icons.person,
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.05,
                        ),
                        child: MyTextField(
                          fieldType: 'Password',
                          text: 'Password',
                          icon: Icons.lock,
                          isObsecure: true,
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      MyButton(
                        title: 'SIGN IN',
                        onPressed: () async {
                          if (email != null &&
                              email!.isNotEmpty &&
                              password != null &&
                              password!.isNotEmpty) {
                            try {
                              String id = await APiService()
                                  .getUserIdByLogin(email!, password!);

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FutureBuilder<UserModel>(
                                    future: APiService().getUserById(id),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const MyLoadingWidget();
                                      } else if (snapshot.hasData) {
                                        return HomeScreen(
                                            userModel: snapshot.data!);
                                      } else {
                                        return const LoginScreen();
                                      }
                                    },
                                  ),
                                ),
                                (route) => false,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Login failed: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please type a valid email or password',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
