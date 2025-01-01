import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/variables.dart';
import 'edit_checkout.dart';
import 'rate_widget.dart';
import 'sub_container.dart';

class CheckOutWidget extends StatelessWidget {
  const CheckOutWidget({
    super.key,
    //required this.data,
    required this.checkInOuts,
    required this.month,
    required this.id,
    required this.index,
    this.employeeName = '',
  });

  //final Map<String, dynamic> data;
  final String month;
  final String id;
  final int index;
  final Map<String, dynamic> checkInOuts;
  final String employeeName;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${checkInOuts['date'][0]}${checkInOuts['date'][1]}${checkInOuts['date'][2]}${checkInOuts['date'][3]}${checkInOuts['date'][4]}${checkInOuts['date'][5]} (${checkInOuts['day'][0]}${checkInOuts['day'][1]}${checkInOuts['day'][2]}) $employeeName',
                style: Styles.style18Black,
              ),
            ),
          ),
          const Divider(thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubCheckOutContainer(
                    data: checkInOuts,
                    width: screenWidth * 0.40,
                  ),
                  SubCheckOutContainer(
                    data: checkInOuts,
                    isCheckIn: false,
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
                        colors: const [appColorLight1, appColorLight2],
                        title: Text(
                          '${checkInOuts['totalWorkTime']['hours'] ?? 0} H, ${checkInOuts['totalWorkTime']['minutes'] ?? 0} Min',
                          style: Styles.style12WhiteBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Shift type: ${checkInOuts['shiftType']}',
              style: Styles.style16Bold,
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Check-Out-details:',
                  style: Styles.style16Bold,
                ),
                (thisUserId == id)
                    ? EditCheckOutWidget(
                        id: id,
                        month: month,
                        dayCheckOut: checkInOuts,
                      )
                    /* ApproveWidget(
                    userModel: userModel,
                    rate: checkInOuts[index]['rate'] as int,
                    month: month,
                  ) */
                    : RateWidget(
                        id: id,
                        rate: (checkInOuts.containsKey('rate')
                            ? checkInOuts['rate']
                            : -1),
                        checkInOut: checkInOuts,
                        month: month,
                      ), //SizedBox(),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${checkInOuts['checkOutDetails']}',
                style: Styles.style16,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
