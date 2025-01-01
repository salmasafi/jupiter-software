// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/services/firebase_api.dart';
import '../../../../../../core/utils/constants.dart';

class RateWidget extends StatefulWidget {
  final String id;
  final Map<String, dynamic> checkInOut;
  final String month;
  int rate;
  RateWidget({
    super.key,
    required this.id,
    required this.rate,
    required this.checkInOut,
    required this.month,
  });

  @override
  State<RateWidget> createState() => _RateWidgetState();
}

class _RateWidgetState extends State<RateWidget> {
  bool isRated = false;
  int lastRate = 0;

  @override
  void initState() {
    super.initState();
    if (widget.rate > -1) {
      isRated = true;
      lastRate = widget.rate;
    } else {
      widget.rate = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (widget.rate > 0) {
                    widget.rate--;
                    setState(() {});
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [appColorLight1, appColorLight2],
                    ),
                  ),
                  width: 50,
                  height: 30,
                  child: const Center(
                    child: Text(
                      '-1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.rate > 0) {
                    widget.rate++;
                    setState(() {});
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [appColorLight1, appColorLight2],
                    ),
                  ),
                  width: 50,
                  height: 30,
                  child: const Center(
                    child: Text(
                      '+1',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${widget.rate}/10',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isRated ? Colors.black : Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: () async {
              DocumentReference employeeDoc1 =
                  FirebaseApi.getEmployeeDocForSpecificDay(
                id: widget.id,
                month: widget.month,
                date: widget.checkInOut['date'],
              );
              DocumentSnapshot employeeSnapshot1 = await employeeDoc1.get();

              DocumentReference employeeDoc2 =
                  FirebaseApi.getEmployeeDoc(id: widget.id);
              DocumentSnapshot employeeSnapshot2 = await employeeDoc2.get();

              if (employeeSnapshot1.exists) {
                await employeeDoc1.update({
                  'rate': widget.rate,
                });
              }

              if (employeeSnapshot2.exists) {
                Map<String, dynamic> rateData = employeeSnapshot2['rate'];
                int totalRate = rateData['totalRate'];
                int daysRating = rateData['daysRating'];

                if (!isRated) {
                  totalRate += widget.rate;
                  daysRating += 1;
                } else {
                  totalRate = totalRate - lastRate + widget.rate;
                }

                await employeeDoc2.update({
                  'rate': {
                    'totalRate': totalRate,
                    'daysRating': daysRating,
                  }
                });

                isRated = true;
                lastRate = widget.rate;
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [appColor1, appColor2],
                ),
              ),
              width: 70,
              height: 30,
              child: const Center(
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
