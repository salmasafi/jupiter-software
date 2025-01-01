// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firebase_api.dart';
import '../presentation/views/month_screen.dart';

class MonthDetailsScreenBuilder extends StatefulWidget {
  final String id;
  final String month;

  const MonthDetailsScreenBuilder({
    super.key,
    required this.id,
    required this.month,
  });

  @override
  _MonthDetailsScreenState createState() => _MonthDetailsScreenState();
}

class _MonthDetailsScreenState extends State<MonthDetailsScreenBuilder> {
  List<Map<String, dynamic>> checkInOuts = [];

  @override
  void initState() {
    super.initState();
    _getCheckInOuts();
  }

  _getCheckInOuts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseApi.getCheckInOutsForThisMonthSnapshot(
        id: widget.id,
        month: widget.month,
      );

      List<Map<String, dynamic>> fetchedData = snapshot.docs.map((doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  num totalWorkTimeAsMinutes = 0;

  totalWorkTimeAsMinutes += ((data['totalWorkTime']?['hours'] ?? 0) * 60);
  totalWorkTimeAsMinutes += (data['totalWorkTime']?['minutes'] ?? 0);

  return {
    'date': doc.id,
    'checkIn': data['checkIn'] ?? '--/--',
    'checkOut': data['checkOut'] ?? '--/--',
    'checkOutDetails': data['checkOutDetails'] ?? '......',
    'day': data['day'] ?? '',
    'totalWorkTime': data['totalWorkTime'] ?? {'hours': 0, 'minutes': 0},
    'totalWorkTimeAsMinutes': totalWorkTimeAsMinutes,
    'rate': data['rate'] ?? -1,
    'shiftType': data['shiftType'] ?? '',
  };
}).toList();


      setState(() {
        checkInOuts = fetchedData.reversed.toList();
      });
    } catch (e) {
      print('Error fetching check-in/out data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MonthDetailsScreen(
        id: widget.id,
        checkInOuts: checkInOuts,
        month: widget.month,
      ),
    );
  }
}
