import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/widgets/build_appbar_method.dart';

class TotalSalaryScreen extends StatefulWidget {
  const TotalSalaryScreen({super.key});

  @override
  State<TotalSalaryScreen> createState() => _TotalSalaryScreenState();
}

class _TotalSalaryScreenState extends State<TotalSalaryScreen> {
  double totalSalaries = 0;
  bool isLoading = false;
  String? selectedMonth;

  List<String> months = [];

  @override
  void initState() {
    super.initState();
    _generateMonthsList();
    selectedMonth = months.isNotEmpty ? months.last : null;
    if (selectedMonth != null) {
      calculateTotalSalaries(selectedMonth!);
    }
  }

  void _generateMonthsList() {
    DateTime startDate = DateTime(2024, 6); // يونيو 2024
    DateTime currentDate = DateTime.now(); // الشهر الحالي
    while (startDate.isBefore(currentDate) ||
        (startDate.year == currentDate.year && startDate.month == currentDate.month)) {
      months.add(DateFormat('MMMM yyyy').format(startDate));
      startDate = DateTime(startDate.year, startDate.month + 1);
    }
  }

  Future<void> calculateTotalSalaries(String month) async {
    setState(() {
      isLoading = true;
      totalSalaries = 0;
    });

    try {
      QuerySnapshot employeeSnapshots = await FirebaseApi.getEmployeesSnapshot();
      for (var doc in employeeSnapshots.docs) {
        await calculateSalaryForEmployee(doc.id, month);
      }
    } catch (e) {
      print('Error calculating total salaries: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> calculateSalaryForEmployee(String employeeId, String month) async {
    double currentSalary = 0;
    int basicSalary = 0;
    double hourSalary = 0;
    int bonus = 0;
    int workedHours = 0;
    int workedMinutes = 0;

    try {
      DocumentSnapshot employeeSnapshot = await FirebaseApi.getEmployeeSnapshot(id: employeeId);

      if (employeeSnapshot.exists &&
          (employeeSnapshot.data() as Map<String, dynamic>).containsKey('salary') &&
          employeeSnapshot['isActive'] == true) {
        basicSalary = employeeSnapshot['salary'];
      }

      int expectedHours = _getExpectedHours(month);

      QuerySnapshot snapshot = await FirebaseApi.getCheckInOutsForThisMonthSnapshot(
        id: employeeId,
        month: month,
      );

      num totalMonthWorkTimeAsMinutes = snapshot.docs.fold(
        0,
            (sum, doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return sum +
              (data['totalWorkTime']['hours'] * 60) +
              data['totalWorkTime']['minutes'];
        },
      );

      while (totalMonthWorkTimeAsMinutes >= 60) {
        totalMonthWorkTimeAsMinutes -= 60;
        workedHours++;
      }
      workedMinutes = totalMonthWorkTimeAsMinutes as int;

      hourSalary = (basicSalary / expectedHours);

      DocumentSnapshot bonusSnapshot = await FirebaseApi.getEmployeeSnapshotForSpecificMonth(
        id: employeeId,
        month: month,
      );
      if (bonusSnapshot.exists && (bonusSnapshot.data() as Map<String, dynamic>).containsKey('bonus')) {
        bonus = int.parse(bonusSnapshot['bonus'].toString());
      }

      double totalWorkedTimeInHours = workedHours + (workedMinutes / 60);
      currentSalary = (hourSalary * totalWorkedTimeInHours) + bonus;
      currentSalary = double.parse(currentSalary.toStringAsFixed(2));

      setState(() {
        totalSalaries += currentSalary;
      });
    } catch (e) {
      print('Error calculating salary for employee: $e');
    }
  }

  int _getExpectedHours(String month) {
    DateTime selectedMonth = DateFormat('MMMM yyyy').parse(month);
    final firstDayOfNextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    final lastDayOfCurrentMonth = firstDayOfNextMonth.subtract(Duration(days: 1));
    final daysInMonth = lastDayOfCurrentMonth.day;

    int fridaysCount = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(selectedMonth.year, selectedMonth.month, i);
      if (day.weekday == DateTime.friday) {
        fridaysCount++;
      }
    }
    return (daysInMonth - fridaysCount) * 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: selectedMonth,
                hint: Text('Select Month'),
                onChanged: (newValue) {
                  setState(() {
                    selectedMonth = newValue;
                  });
                  if (newValue != null) {
                    calculateTotalSalaries(newValue);
                  }
                },
                items: months.map((month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : Column(
                children: [
                  Text(
                    'Total Salary for $selectedMonth:',
                    style: Styles.style18BlackBold,
                  ),
                  Text(
                    '$totalSalaries',
                    style: Styles.style18BlackBold,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
