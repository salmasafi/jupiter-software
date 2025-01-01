import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/utils/variables.dart';
import '../../../../core/widgets/build_appbar_method.dart';
import '../../../../core/widgets/mybutton.dart';
import '../../../login/logic/models/user_model.dart';
import 'package:jupiter_academy/core/utils/styles.dart';
import 'add_bonus_screen.dart';
import 'employee_data.dart';

class SalaryScreen extends StatefulWidget {
  final UserModel userModel;
  const SalaryScreen({super.key, required this.userModel});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  int expectedHours = 0;
  int basicSalary = 0;
  double currentSalary = 0;
  double hourSalary = 0;
  int bonus = 0;
  int workedHours = 0;
  num workedMinutes = 0;

  List<String> monthsList = [];
  String selectedMonth = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await getSalary();
    await getMonths();
    _getExpectedHours();
    calculateSalary();
  }

  void _getExpectedHours() {
    if (selectedMonth.isEmpty) return;

    DateTime selectedMonthDate = DateFormat('MMMM yyyy').parse(selectedMonth);
    final firstDayOfNextMonth = DateTime(selectedMonthDate.year, selectedMonthDate.month + 1, 1);
    final lastDayOfCurrentMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
    final daysInMonth = lastDayOfCurrentMonth.day;

    int fridaysCount = 0;

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(selectedMonthDate.year, selectedMonthDate.month, i);
      if (day.weekday == DateTime.friday) {
        fridaysCount++;
      }
    }

    setState(() {
      expectedHours = (daysInMonth - fridaysCount) * 6;
    });
  }

  Future<void> getMonths() async {
    try {
      var monthsSnapshot = await FirebaseApi.getMonthsSnapshot(id: widget.userModel.id);
      List<String> fetchedMonthsList = monthsSnapshot.docs.map((doc) => doc.id).toList();

      fetchedMonthsList.sort((a, b) {
        DateTime monthA = DateFormat('MMMM yyyy').parse(a);
        DateTime monthB = DateFormat('MMMM yyyy').parse(b);
        return monthA.compareTo(monthB);
      });

      setState(() {
        monthsList = fetchedMonthsList;
        if (monthsList.isNotEmpty) {
          selectedMonth = monthsList.last;
          updateSalaryDetailsForSelectedMonth();
          _getExpectedHours();
        }
      });
    } catch (e) {
      print('Error retrieving months: $e');
    }
  }

  Future<void> updateSalaryDetailsForSelectedMonth() async {
    await getBonus();
    await getCheckInOuts();
    calculateHourSalary();
    calculateSalary();
  }

  Future<void> getSalary() async {
    try {
      DocumentSnapshot employeeSnapshot = await FirebaseApi.getEmployeeSnapshot(id: widget.userModel.id);
      if (employeeSnapshot.exists) {
        setState(() {
          basicSalary = employeeSnapshot['salary'];
        });
      }
    } catch (e) {
      print('Error retrieving salary: $e');
    }
  }

  Future<void> getBonus() async {
    try {
      DocumentSnapshot employeeSnapshot = await FirebaseApi.getEmployeeSnapshotForSpecificMonth(
          id: widget.userModel.id, month: selectedMonth
      );
      setState(() {
        bonus = employeeSnapshot['bonus'] ?? 0;
      });
    } catch (e) {
      print('Error retrieving bonus: $e');
    }
  }

  List<Map<String, dynamic>> checkInOuts = [];
  Future<void> getCheckInOuts() async {
    try {
      QuerySnapshot snapshot = await FirebaseApi.getCheckInOutsForThisMonthSnapshot(
          id: widget.userModel.id, month: selectedMonth
      );
      List<Map<String, dynamic>> fetchedData = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        num totalWorkTimeAsMinutes = 0;
        totalWorkTimeAsMinutes += (data['totalWorkTime']['hours'] * 60);
        totalWorkTimeAsMinutes += data['totalWorkTime']['minutes'];
        return {
          'date': doc.id,
          'totalWorkTimeAsMinutes': totalWorkTimeAsMinutes as int,
        };
      }).toList();

      setState(() {
        checkInOuts = fetchedData;
        calculateMonthWorkTime(checkInOuts);
      });
    } catch (e) {
      print('Error fetching check-in/out data: $e');
    }
  }

  void calculateMonthWorkTime(List<Map<String, dynamic>> checkInOuts) {
    num totalMinutes = checkInOuts.fold(0, (sum, item) => sum + item['totalWorkTimeAsMinutes']);
    setState(() {
      workedHours = totalMinutes ~/ 60;
      workedMinutes = totalMinutes % 60;
    });
  }

  void calculateHourSalary() {
    if (expectedHours == 0) return;

    setState(() {
      hourSalary = basicSalary / expectedHours;
    });
  }

  void calculateSalary() {
    double totalWorkedTimeInHours = workedHours + (workedMinutes / 60);
    setState(() {
      currentSalary = double.parse(((hourSalary * totalWorkedTimeInHours) + bonus).toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 150),
              DropdownButton<String>(
                value: selectedMonth,
                items: monthsList.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (newMonth) {
                  setState(() {
                    selectedMonth = newMonth!;
                  });
                  updateSalaryDetailsForSelectedMonth();
                  _getExpectedHours();
                },
              ),
              const SizedBox(height: 20),
              Text('Basic salary: $basicSalary', style: Styles.style16Bold),
              Text('Expected hours: $expectedHours', style: Styles.style16Bold),
              Text('Hour salary: $hourSalary', style: Styles.style16Bold),
              Text('Worked time: $workedHours h, $workedMinutes m', style: Styles.style16Bold),
              Text('Bonus: $bonus', style: Styles.style16Bold),
              const SizedBox(height: 20),
              Text('Current salary: $currentSalary', style: Styles.style16Bold),
              const SizedBox(height: 20),
              (thisUserId == 'd666da61-11ed-48d2-bee7-f994d85e6be0' ||
                  thisUserId == '670b2538-9ff7-414d-9f21-dbe7b6bfa8a9')
                  ? Column(
                children: [
                  MyButton(
                    title: 'Edit employee\'s salary',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeData(
                            userModel: widget.userModel,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  MyButton(
                    title: 'Add Bonus',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBonusScreen(
                            month: selectedMonth,
                            userModel: widget.userModel,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ) : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
