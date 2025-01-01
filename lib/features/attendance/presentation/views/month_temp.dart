/* import 'package:flutter/material.dart';
import 'package:jupiter_academy/core/utils/constants.dart';
import 'package:jupiter_academy/core/widgets/white_container.dart';
import 'package:jupiter_academy/features/attendance/logic/month_screen_builder.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/variables.dart';
import '../widgets/edit_checkout.dart';
import '../widgets/rate_widget.dart';

class MonthDetailsScreen extends StatefulWidget {
  const MonthDetailsScreen({
    super.key,
    required this.checkInOuts,
    required this.id,
    required this.month,
    required this.name,
  });

  final List<Map<String, dynamic>> checkInOuts;
  final String id;
  final String month;
  final String name;

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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            '${widget.name}\'s checkOuts',
            style: Styles.style18WhiteBold,
          ),
        ),
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
              gradient: LinearGradient(
                colors: [appColorLight1, appColorLight2],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        Expanded(
          child: WhiteBorderRadiusContainer(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: dataNotifier,
              builder: (context, dataList, child) {
                return ListView.builder(
                        itemCount: dataList.length,
                        itemBuilder: (context, index) {
                          final data = dataList[index];
                          return CheckOutWidget(
                            data: data,
                            widget: widget,
                            index: index,
                          );
                        },
                      );
              }
            ),
          ),
        ),
      ],
    );
  }
}


class CheckOutWidget extends StatelessWidget {
  const CheckOutWidget({
    super.key,
    required this.data,
    required this.widget,
    required this.index,
  });

  final Map<String, dynamic> data;
  final MonthDetailsScreen widget;
  final int index;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Flexible(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${data['date']} (${data['day'][0]}${data['day'][1]}${data['day'][2]})',
                  style: Styles.style18Black,
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SubCheckOutContainer(
                      data: data,
                      //height: screenHeight * 0.043,
                      width: screenWidth * 0.40,
                    ),
                    SubCheckOutContainer(
                      data: data,
                      isCheckIn: false,
                      //height: screenHeight * 0.043,
                      width: screenWidth * 0.40,
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.14,
                  width: screenWidth * 0.40,
                  child: SubContainer(
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Work Time: ',
                          style: Styles.style14Bold,
                        ),
                        SubContainer(
                          width: screenWidth * 0.40,
                          colors: [appColorLight1, appColorLight2],
                          title: Text(
                            '${data['totalWorkTime']['hours'] ?? 0} H, ${data['totalWorkTime']['minutes'] ?? 0} Min',
                            style: Styles.style12WhiteBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Check-Out-details:',
                  style: Styles.style16Bold,
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${data['checkOutDetails']}',
                  style: Styles.style16,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubCheckOutContainer extends StatelessWidget {
  SubCheckOutContainer({
    super.key,
    required this.data,
    this.isCheckIn = true,
    this.height,
    this.width,
  });
  bool isCheckIn;
  final Map<String, dynamic> data;
  double? height;
  double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey[200],
      ),
      child: Flexible(
        child: Center(
          child: Text(
            isCheckIn
                ? 'Check-In: ${data['checkIn']}'
                : 'Check-Out: ${data['checkOut']}',
            style: Styles.style14Bold,
          ),
        ),
      ),
    );
  }
}

class SubContainer extends StatelessWidget {
  SubContainer(
      {super.key, required this.title, this.height, this.width, this.colors});

  final Widget title;
  double? height;
  double? width;
  List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: colors == null ? Colors.grey[200] : null,
        gradient: colors != null ? LinearGradient(colors: colors!) : null,
      ),
      child: Flexible(
        child: Center(
          child: title,
        ),
      ),
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
*/ */