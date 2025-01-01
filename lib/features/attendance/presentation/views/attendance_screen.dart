import 'package:flutter/material.dart';
import '../../../../core/utils/styles.dart';
import '../../../profile/presentation/widgets/purple_stars_background.dart';
import '../../logic/month_screen_builder.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AttendanceScreen extends StatefulWidget {
  final List<String> months;
  final String id;
  final String name;

  const AttendanceScreen({
    super.key,
    required this.months,
    required this.id,
    required this.name,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.months[0];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      //appBar: buildAppBar(),
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
              CustomAppBar(title: '${widget.name} check-outs',),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        items: widget.months
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
                            selectedValue = value ?? widget.months[0];
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
                            thumbVisibility:
                                WidgetStateProperty.all<bool>(true),
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
              MonthDetailsScreenBuilder(
                key: ValueKey(selectedValue),
                id: widget.id,
                month: selectedValue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: Styles.style18WhiteBold,
        ),
      ],
    );
  }
}
