import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/cubit/jupiter_cubit.dart';
import 'core/services/api_service.dart';
import 'core/services/notification_api.dart';
import 'core/widgets/jupiter_widget.dart';
import 'core/widgets/loadingwidget.dart';
import 'features/attendance/logic/attendance_screen_builder.dart';
import 'features/login/presentation/views/loginscreen.dart';
import 'features/home/presentation/views/homescreen.dart';
import 'features/login/logic/models/user_model.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool openedFromNotification = false;
String? employeeIdNotifi;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationApi().initNotifacations();
  NotificationApi().configLocalNotifi();
  await NotificationHandler.initialize();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<bool> loginStatusFuture;

  @override
  void initState() {
    super.initState();
    loginStatusFuture = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  Widget _buildHomeScreen() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const JupiterWidget();
        } else if (snapshot.hasData) {
          final prefs = snapshot.data!;
          final userId = prefs.getString('userId')!;
          return FutureBuilder<UserModel>(
            future: APiService().getUserById(userId),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const JupiterWidget();
              } else if (userSnapshot.hasData) {
                return HomeScreen(
                  userModel: userSnapshot.data!,
                );
              } else {
                return const LoginScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JupiterCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: FutureBuilder<bool>(
          future: loginStatusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MyLoadingWidget();
            } else if (openedFromNotification) {
              return AttendanceScreenBuilder(
                id: employeeIdNotifi ?? '',
              );
            } else if (snapshot.hasData && snapshot.data == true) {
              return _buildHomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

class NotificationHandler {
  static RemoteMessage? initialMessage;

  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      openedFromNotification = true;
      employeeIdNotifi = initialMessage!.data['employeeId'];
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      openedFromNotification = true;
      employeeIdNotifi = message.data['employeeId'];
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AttendanceScreenBuilder(
            id: employeeIdNotifi ?? '',
          ),
        ),
      );
    });
  }
}
