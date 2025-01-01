// ignore_for_file: must_be_immutable

import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';
import 'package:flutter/material.dart';
import '../utils/styles.dart';

class MyListTile extends StatelessWidget {
  final String title;
  bool canEdit;
  String iconType;
  VoidCallback? onTap;
  String? data;
  bool isClickable;

  MyListTile({
    super.key,
    required this.title,
    this.canEdit = false,
    this.onTap,
    this.iconType = 'edit',
    this.data,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: myPurple.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        title: SelectableText(
          title,
          style: Styles.style22,
        ),
        trailing: canEdit != false
            ? IconButton(
                onPressed: onTap,
                icon: const Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
              )
            : iconType == 'copy'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isClickable ? IconButton(
                        onPressed: () async {
                          String url = data ?? '';
                          print(data);
                          Uri uri = Uri.parse(url);
                          try {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              print('Could not launch $url');
                            }
                          } catch (e) {
                            print('Error launching URL: $e');
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Colors.black,
                        ),
                      ) : const SizedBox(),
                      IconButton(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                : null,
      ),
    );
  }
}

class MySquareTile extends StatelessWidget {
  double? width;
  double? height;
  VoidCallback? onTap;
  Widget? child;
  MySquareTile({
    super.key,
    this.child,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: myPurple,
          borderRadius: BorderRadius.circular(20),
        ),
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
