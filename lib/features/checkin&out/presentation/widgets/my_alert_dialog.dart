// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String body;
  final Future<void> Function() onYes;
  bool yesAndNo;
  MyAlertDialog({
    super.key,
    required this.title,
    required this.body,
    required this.onYes,
    this.yesAndNo = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(body),
          ],
        ),
      ),
      actions: [
        yesAndNo ? TextButton(
          child: const Text('Yes'),
          onPressed: () async {
            await onYes();
          },
        ) : TextButton(
          child: const Text('Ok'),
          onPressed: () async {
            await onYes();
          },
        ),
        yesAndNo ? TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ) : const SizedBox(),
      ],
    );
  }
}
