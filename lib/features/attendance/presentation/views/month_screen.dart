import 'package:flutter/material.dart';
import 'package:jupiter_academy/core/widgets/white_container.dart';
import 'package:jupiter_academy/features/attendance/presentation/widgets/checkout_widget.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/styles.dart';

class MonthDetailsScreen extends StatefulWidget {
  const MonthDetailsScreen({
    super.key,
    required this.checkInOuts,
    required this.id,
    required this.month,
  });

  final List<Map<String, dynamic>> checkInOuts;
  final String id;
  final String month;

  @override
  State<MonthDetailsScreen> createState() => _MonthDetailsScreenState();
}

class _MonthDetailsScreenState extends State<MonthDetailsScreen> {
  Map<String, dynamic> calculateMonthWorkTime(
      final List<Map<String, dynamic>> checkInOuts) {
    num totalMonthWorkTimeAsMinutes = 0;
    for (var checkInOut in checkInOuts) {
      totalMonthWorkTimeAsMinutes +=
          checkInOut['totalWorkTimeAsMinutes'] as int;
    }

    print(totalMonthWorkTimeAsMinutes);

    Map<String, dynamic> totalWorkTime = {'hours': 0, 'minutes': 0};

    while (totalMonthWorkTimeAsMinutes >= 60) {
      totalMonthWorkTimeAsMinutes -= 60;
      totalWorkTime['hours'] += 1;
    }

    totalWorkTime['minutes'] = totalMonthWorkTimeAsMinutes;

    return totalWorkTime;
  }

  int _getDaysInCurrentMonthExcludingFridays() {
    final now = DateTime.now();
    final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final lastDayOfCurrentMonth =
        firstDayOfNextMonth.subtract(Duration(days: 1));
    final daysInMonth = lastDayOfCurrentMonth.day;

    int fridaysCount = 0;

    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      if (day.weekday == DateTime.friday) {
        fridaysCount++;
      }
    }

    return daysInMonth - fridaysCount;
  }

  @override
  Widget build(BuildContext context) {
    double progress = (calculateMonthWorkTime(widget.checkInOuts)['hours'] +
            (calculateMonthWorkTime(widget.checkInOuts)['minutes'] / 60)) /
        (_getDaysInCurrentMonthExcludingFridays() * 6);

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.020),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            '${widget.checkInOuts.length} d, ${calculateMonthWorkTime(widget.checkInOuts)['hours']} h, ${calculateMonthWorkTime(widget.checkInOuts)['minutes']} min',
            style: Styles.style18WhiteBold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            height: 15,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [appColorLight1, appColorLight2],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${calculateMonthWorkTime(widget.checkInOuts)['hours']} h, ${calculateMonthWorkTime(widget.checkInOuts)['minutes']} m',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}% Completed',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                '${_getDaysInCurrentMonthExcludingFridays() * 6} h',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        SizedBox(
          height: screenHeight * 0.678,
          child: WhiteBorderRadiusContainer(
            screenHeight: screenHeight  * 0.678,
            screenWidth: screenWidth,
            child: ListView.builder(
              //shrinkWrap: true,
              // ignore: prefer_const_constructors
              //physics: NeverScrollableScrollPhysics(),
              itemCount: widget.checkInOuts.length,
              itemBuilder: (context, index) {
                return CheckOutWidget(
                  checkInOuts: widget.checkInOuts[index],
                  month: widget.month,
                  id: widget.id,
                  index: index,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}



/*
(thisUserId == widget.id)
              ? EditCheckOutWidget(
                  id: widget.id,
                  name: widget.name,
                  month: widget.month,
                  dayCheckOut: data,
                ) /* ApproveWidget(
                    userModel: userModel,
                    rate: checkInOuts[index]['rate'] as int,
                    month: month,
                  ) */
              : RateWidget(
                  id: widget.id,
                  rate: (widget.checkInOuts[index]['rate']),
                  checkInOut: data,
                  month: widget.month,
                ),
 */