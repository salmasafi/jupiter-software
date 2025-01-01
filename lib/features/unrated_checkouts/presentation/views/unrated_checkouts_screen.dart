import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jupiter_academy/core/widgets/white_container.dart';
import 'package:jupiter_academy/features/attendance/presentation/widgets/checkout_widget.dart';
import 'package:jupiter_academy/features/unrated_checkouts/logic/models/employee_forcheckout.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../attendance/presentation/views/attendance_screen.dart';
import '../../../profile/presentation/widgets/purple_stars_background.dart';

class UnratedCheckoutsScreen extends StatefulWidget {
  const UnratedCheckoutsScreen({super.key});

  @override
  State<UnratedCheckoutsScreen> createState() => _UnratedCheckoutsScreenState();
}

class _UnratedCheckoutsScreenState extends State<UnratedCheckoutsScreen> {
  late String selectedValue;
  List<UnratedCheckOut> unratedCheckOuts = [];
  List<Map<String, dynamic>> unratedCheckOutList = [];
  List<String> months = [];

  Future<String> _getName(String id) async {
    try {
      var employeeSnapshot = await FirebaseApi.getEmployeeSnapshot(id: id);
      return employeeSnapshot.exists ? employeeSnapshot['name'] : '';
    } catch (e) {
      print('Error fetching name: $e');
      return '';
    }
  }

  _getUnratedCheckOuts(String month) async {
    // Clear existing data
    unratedCheckOuts.clear();
    unratedCheckOutList.clear();

    List<EmployeeForcheckout> employeesModels = [];
    try {
      QuerySnapshot employeesSnapshot = await FirebaseApi.getEmployeesSnapshot();
      for (var doc in employeesSnapshot.docs) {
        String name = await _getName(doc.id);
        employeesModels.add(EmployeeForcheckout(name, doc.id));
      }
    } catch (e) {
      print('Error fetching all employees: $e');
    }

    // Get checkouts for selected month
    try {
      for (var employeeModel in employeesModels) {
        QuerySnapshot snapshot = await FirebaseApi.getCheckInOutsForThisMonthSnapshot(
          id: employeeModel.id,
          month: month,
        );

        List<Map<String, dynamic>?> fetchedData = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if (data.containsKey('rate') && data['rate'] != -1) {
            return null;
          }

          num totalWorkTimeAsMinutes = (data['totalWorkTime']['hours'] * 60) +
              data['totalWorkTime']['minutes'];

          return {
            'date': doc.id,
            'checkIn': data.containsKey('checkIn') ? data['checkIn'] : '--/--',
            'checkOut': data.containsKey('checkOut') ? data['checkOut'] : '--/--',
            'checkOutDetails': data.containsKey('checkOutDetails') ? data['checkOutDetails'] : '......',
            'day': data.containsKey('day') ? data['day'] : '',
            'totalWorkTime': data.containsKey('totalWorkTime') ? data['totalWorkTime'] : {'hours': 0, 'minutes': 0},
            'totalWorkTimeAsMinutes': totalWorkTimeAsMinutes as int,
            'rate': data.containsKey('rate') ? data['rate'] : -1,
          };
        }).toList();

        setState(() {
          unratedCheckOuts.add(UnratedCheckOut(employeeModel, fetchedData.reversed.toList()));
        });
      }
    } catch (e) {
      print('Error fetching check-in/out data: $e');
    }
    _makeUnratedCheckOutList(); // Call this to update the list
  }

  void _makeUnratedCheckOutList() {
    unratedCheckOutList.clear();

    for (UnratedCheckOut unratedCheckOut in unratedCheckOuts) {
      for (Map<String, dynamic>? unratedDay in unratedCheckOut.checkInOuts) {
        if (unratedDay != null) {
          unratedDay['employeeName'] = unratedCheckOut.employeeForcheckout.name;
          unratedDay['employeeId'] = unratedCheckOut.employeeForcheckout.id;
          unratedCheckOutList.add(unratedDay);
        }
      }
    }

    unratedCheckOutList.sort((a, b) {
      DateTime dateA = DateFormat('d MMMM yyyy').parse(a['date']);
      DateTime dateB = DateFormat('d MMMM yyyy').parse(b['date']);
      return dateB.compareTo(dateA);
    });

    setState(() {});
  }

  _fetchData() async {
   _generateMonthsList();
    await _getUnratedCheckOuts(selectedValue); // Pass the initially selected month
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
  // _getMonths() async {
  //   try {
  //     var monthsSnapshot = await FirebaseApi.getMonthsSnapshot(id: 'd666da61-11ed-48d2-bee7-f994d85e6be0');
  //     List<String> monthsList = [];

  //     monthsSnapshot.docs.forEach((doc) {
  //       monthsList.add(doc.id);
  //     });

  //     List<String> monthOrder = [
  //       'January', 'February', 'March', 'April', 'May', 'June',
  //       'July', 'August', 'September', 'October', 'November', 'December'
  //     ];

  //     monthsList.sort((a, b) {
  //       String monthA = a.split(' ')[0];
  //       int yearA = int.parse(a.split(' ')[1]);
  //       String monthB = b.split(' ')[0];
  //       int yearB = int.parse(b.split(' ')[1]);
  //       int yearComparison = yearA.compareTo(yearB);
  //       if (yearComparison != 0) return yearComparison;
  //       return monthOrder.indexOf(monthA).compareTo(monthOrder.indexOf(monthB));
  //     });

  //     setState(() {
  //       months = monthsList.reversed.toList();
  //       selectedValue = months[0];
  //     });
  //   } catch (e) {
  //     print('Error retrieving months: $e');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Stack(
        children: [
          PurpleStarsBackground(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.050),
              CustomAppBar(
                title: 'Requests for $selectedValue',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        items: months
                            .map(
                              (String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                            .toList(),
                        value: selectedValue, // Use selectedValue instead of months[0]
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedValue = value;
                            });
                            _getUnratedCheckOuts(value); // Fetch new data based on selected month
                          }
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          width: screenWidth * 0.5,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white,
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                          iconSize: 14,
                          iconEnabledColor: Colors.black26,
                          iconDisabledColor: Colors.black26,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                          ),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: WidgetStateProperty.all<double>(6),
                            thumbVisibility: WidgetStateProperty.all<bool>(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              UnratedCheckOutsWidget(
                key: ValueKey(selectedValue),
                unratedCheckOutList: unratedCheckOutList,
                month: selectedValue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UnratedCheckOutsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> unratedCheckOutList;
  final String month;

  const UnratedCheckOutsWidget({
    Key? key,
    required this.unratedCheckOutList,
    required this.month,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return WhiteBorderRadiusContainer(
      screenHeight: screenHeight * 0.808,
      screenWidth: screenWidth,
      child: SizedBox(
        height: screenHeight * 0.85,
        child: unratedCheckOutList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: unratedCheckOutList.length,
          itemBuilder: (context, index) =>
          unratedCheckOutList[index].isNotEmpty
              ? CheckOutWidget(
            checkInOuts: unratedCheckOutList[index],
            month: month,
            id: unratedCheckOutList[index]
            ['employeeId'], // تمرير ID الموظف
            employeeName: unratedCheckOutList[index]
            ['employeeName'], // تمرير اسم الموظف
            index: index,
          )
              : const SizedBox(),
        ),
      ),
    );

  }
}





