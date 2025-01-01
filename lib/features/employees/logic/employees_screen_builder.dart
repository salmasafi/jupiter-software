import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/variables.dart';
import '../../../core/widgets/build_appbar_method.dart';
import '../../../core/widgets/errorwidget.dart';
import '../../../core/widgets/myemptyscreen.dart';
import 'models/employee_model.dart';
import '../presentation/views/employees_screen.dart';

class EmployeeBranchScreenBuilder extends StatefulWidget {
  const EmployeeBranchScreenBuilder({super.key});

  @override
  State<EmployeeBranchScreenBuilder> createState() =>
      _EmployeeBranchScreenBuilderState();
}

class _EmployeeBranchScreenBuilderState
    extends State<EmployeeBranchScreenBuilder> {
  late String selectedValue;
  late List<String> branches;

  @override
  void initState() {
    if (Branch == 'Asafra') {
      branches = ['Asafra', 'Bitash'];
    } else {
      branches = ['Bitash', 'Asafra'];
    }
    selectedValue = branches[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    //final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    items: branches
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
                    value: selectedValue,
                    onChanged: (String? value) {
                      setState(() {
                        selectedValue = value ?? branches[0];
                      });
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
          EmployeesScreenBuilder(
            key: ValueKey(selectedValue),
            branch: selectedValue,
          ),
        ],
      ),
    );
  }
}

class EmployeesScreenBuilder extends StatefulWidget {
  final String branch;
  const EmployeesScreenBuilder({
    super.key,
    required this.branch,
  });

  @override
  State<EmployeesScreenBuilder> createState() => _EmployeesScreenBuilderState();
}

class _EmployeesScreenBuilderState extends State<EmployeesScreenBuilder> {
  Future<List<Employee>> getEmployees() async {
    return await APiService().getEmployees(
      branch: widget.branch,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Employee>>(
      future: getEmployees(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return EmployeesScreen(employees: snapshot.data as List<Employee>);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return const MyErrorWidget();
        } else {
          return const EmptyScreen(title: 'employees');
        }
      },
    );
  }
}
