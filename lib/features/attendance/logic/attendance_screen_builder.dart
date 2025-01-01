// ignore_for_file: library_private_types_in_public_api, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:flutter/material.dart';
import '../../../core/services/firebase_api.dart';
import '../presentation/views/attendance_screen.dart';

class AttendanceScreenBuilder extends StatefulWidget {
  final String id;

  const AttendanceScreenBuilder({
    super.key,
    required this.id,
  });

  @override
  _AttendanceScreenBuilderState createState() =>
      _AttendanceScreenBuilderState();
}

class _AttendanceScreenBuilderState extends State<AttendanceScreenBuilder> {
  List<String> months = [];
  String? name;

  @override
  void initState() {
    super.initState();
    _getMonths();
    _getName();
  }

  _getName() async {
    try {
      var employeeSnapshot =
          await FirebaseApi.getEmployeeSnapshot(id: widget.id);

      if (employeeSnapshot.exists) {
        setState(() {
          name = employeeSnapshot['name'];
          print(name);
        });
      }
    } catch (e) {
      print('Error fetching name: $e');
    }
  }

  _getMonths() async {
    try {
      var monthsSnapshot =
          await FirebaseApi.getMonthsSnapshot(id: widget.id);

      List<String> monthsList = [];

      monthsSnapshot.docs.forEach((doc) {
        monthsList.add(doc.id);
      });

      // ترتيب الشهور حسب ترتيبها في السنة مع الأخذ في الاعتبار السنة
      List<String> monthOrder = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

      monthsList.sort((a, b) {
        // استخراج الشهر والسنة
        String monthA = a.split(' ')[0];
        int yearA = int.parse(a.split(' ')[1]);
        String monthB = b.split(' ')[0];
        int yearB = int.parse(b.split(' ')[1]);

        // مقارنة السنوات أولاً
        int yearComparison = yearA.compareTo(yearB);
        if (yearComparison != 0) {
          return yearComparison;
        }

        // إذا كانت السنوات متساوية، مقارنة الشهور
        return monthOrder.indexOf(monthA).compareTo(monthOrder.indexOf(monthB));
      });

      setState(() {
        months = monthsList.reversed.toList();
      });

      print(months);
    } catch (e) {
      print('Error retrieving months: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AttendanceScreen(
      months: months,
      id: widget.id,
      name: name ?? '',
    );
  }
}
