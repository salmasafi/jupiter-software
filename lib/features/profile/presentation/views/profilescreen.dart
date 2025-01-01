// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupiter_academy/core/utils/styles.dart';
import 'package:jupiter_academy/core/widgets/mytextfield.dart';
import 'package:jupiter_academy/core/widgets/white_container.dart';
import 'package:jupiter_academy/features/attendance/presentation/widgets/sub_container.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/cubit/jupiter_cubit.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/firebase_api.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/variables.dart';
import '../../../../core/widgets/stars_widget.dart';
import '../../../login/logic/models/user_model.dart';
import '../../logic/image_change_builder.dart';
import '../widgets/done_widget.dart';
import '../widgets/purple_stars_background.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _totalRating = 0.0;
  int _rating = 0;
  int _daysRating = 0;

  Future<void> _fetchRating() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseApi.getEmployeeSnapshot(id: widget.userModel.id);

      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        _rating = data['rate']['totalRate'];
        _daysRating = data['rate']['daysRating'];

        if (_daysRating != 0) {
          setState(() {
            _totalRating = (_rating / _daysRating) / 2;
          });
        } else {
          setState(() {
            _totalRating = 0.0;
          });
        }
      } else {
        print('error while fetching data');
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  TextEditingController userNameController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController instapayLinkController = TextEditingController();
  TextEditingController cashWalletController = TextEditingController();
  TextEditingController cardHolderNameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  editPaymentInfo() async {
    bool result = await APiService().changePaymentInfo(
      userModel: widget.userModel,
      instapayLink: instapayLinkController.text,
      cashWallet: cashWalletController.text,
      cardHolderName: cardHolderNameController.text,
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'PaymentInfo have changed successfully',
          ),
        ),
      );
      widget.userModel.instapayLink = instapayLinkController.text;
      widget.userModel.cashWallet = cashWalletController.text;
      widget.userModel.cardHolderName = cardHolderNameController.text;
      //Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'There\'s an error in changing payment info, Please try again',
          ),
        ),
      );
    }
  }

  changePassword() async {
    late String result;

    try {
      result = await APiService().changePassword(widget.userModel.id,
          oldPasswordController.text, newPasswordController.text);
    } catch (e) {
      result = 'Error';
    }
    if (result == 'Done') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password have changed successfully',
          ),
        ),
      );
      //Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'There\'s an error in changing password, Please try again',
          ),
        ),
      );
    }
  }

  bool isDataChanged = false;

  String? instapayLinkTemp;
  String? cashWalletTemp;
  String? cardNameHolderTemp;

  @override
  void initState() {
    super.initState();
    setState(() {
      userNameController.text = widget.userModel.userName;
      roleController.text = widget.userModel.role;
      branchController.text = widget.userModel.branch;
      phoneNumberController.text = widget.userModel.phoneNumber;

      instapayLinkController.text = widget.userModel.instapayLink;
      instapayLinkTemp = widget.userModel.instapayLink;

      cashWalletController.text = widget.userModel.cashWallet;
      cashWalletTemp = widget.userModel.cashWallet;

      cardHolderNameController.text = widget.userModel.cardHolderName;
      cardNameHolderTemp = widget.userModel.cardHolderName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      //appBar: buildAppBar(),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PurpleStarsBackground(
              screenHeight: screenHeight, screenWidth: screenWidth),
          SingleChildScrollView(
            child: SafeArea(
              child: SizedBox(
                height: screenHeight * 1.2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6, right: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                'My Profile',
                                style: Styles.style18WhiteBold,
                              ),
                            ],
                          ),
                          DoneWidget(
                            key: ValueKey(isDataChanged),
                            isDataChanged: isDataChanged,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            onTap: () async {
                              if (isDataChanged) {
                                if (instapayLinkTemp !=
                                        instapayLinkController.text ||
                                    cardNameHolderTemp !=
                                        cardHolderNameController.text ||
                                    cashWalletTemp !=
                                        cashWalletController.text) {
                                  editPaymentInfo();
                                }
                                if (oldPasswordController.text != '' &&
                                    newPasswordController.text != '') {
                                  if (oldPasswordController.text ==
                                      newPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Old password and new one can not be the same, Please choose another password',
                                        ),
                                      ),
                                    );
                                  } else {
                                    changePassword();
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: WhiteBorderRadiusContainer(
                        screenHeight: screenHeight * 1.112,
                        screenWidth: screenWidth,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            //vertical: screenHeight * 0.02,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.30,
                                        height: screenWidth * 0.30,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: BlocBuilder<JupiterCubit,
                                              JupiterState>(
                                            builder: (context, state) {
                                              String imageUrl;
                                              if (state is ImageChangedState &&
                                                  state.imageUrl != null) {
                                                imageUrl = state.imageUrl!;
                                              } else {
                                                imageUrl = widget.userModel
                                                                .profileImagePath !=
                                                            '' &&
                                                        widget.userModel
                                                                .profileImagePath !=
                                                            ''
                                                    ? widget.userModel
                                                        .profileImagePath
                                                    : 'https://jupiter-academy.org/assets/images/Jupiter%20Outlined.png';
                                              }
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10000),
                                                clipBehavior: Clip.antiAlias,
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  height: screenWidth * 0.6,
                                                  width: screenWidth * 0.6,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      SizedBox(
                                        // width: screenWidth * 0.30,
                                        height: screenWidth * 0.30,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            widget.userModel.id == thisUserId
                                                ? Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ImageChangeBuilder(
                                                                userModel: widget
                                                                    .userModel,
                                                              ),
                                                            ),
                                                          );
                                                          BlocProvider.of<
                                                                      JupiterCubit>(
                                                                  context)
                                                              .changeImage(
                                                                  widget
                                                                      .userModel
                                                                      .id);
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            Builder(
                                              builder: (context) {
                                                _fetchRating();
                                                return Center(
                                                  child: StarsWidget(
                                                      initialRating:
                                                          _totalRating),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyTextField(
                                        controller: userNameController,
                                        readOnly: true,
                                        text: 'Username',
                                        labelColor: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: MyTextField(
                                        controller: roleController,
                                        readOnly: true,
                                        text: 'Role',
                                        labelColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyTextField(
                                        controller: branchController,
                                        readOnly: true,
                                        text: 'Branch',
                                        labelColor: Colors.black,
                                      ),
                                    ),
                                    Expanded(
                                      child: MyTextField(
                                        controller: phoneNumberController,
                                        readOnly: true,
                                        text: 'Phone Number',
                                        labelColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SubContainer(
                                      height: screenHeight * 0.05,
                                      width: screenWidth * 0.37,
                                      title: Text(
                                        'Payment Info',
                                        style: Styles.style14WhiteBold,
                                      ),
                                      colors: const [
                                        appColorLight1,
                                        appColorLight2
                                      ],
                                    ),
                                    widget.userModel.id != thisUserId
                                        ? IconButton(
                                            onPressed: () async {
                                              String instapayLink =
                                                  instapayLinkController.text;

                                              if (instapayLink.isNotEmpty) {
                                                Uri uri =
                                                    Uri.parse(instapayLink);

                                                try {
                                                  if (await canLaunchUrl(uri)) {
                                                    await launchUrl(uri,
                                                        mode: LaunchMode
                                                            .externalApplication);
                                                    print(
                                                        'Open Instapay link done');
                                                  } else {
                                                    print(
                                                        'Could not launch $instapayLink');
                                                  }
                                                } catch (e) {
                                                  print(
                                                      'Error launching URL: $e');
                                                }
                                              } else {
                                                print(
                                                    'Username not found in payment info');
                                              }
                                            },
                                            icon: const Icon(Icons.link),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight * 0.01,
                                ),
                                MyTextField(
                                  controller: instapayLinkController,
                                  text: 'InstaPay Link/Card Number',
                                  readOnly: widget.userModel.id != thisUserId,
                                  labelColor: Colors.black,
                                  onChanged: (value) {
                                    if (instapayLinkTemp != value) {
                                      isDataChanged = true;
                                    } else {
                                      if (cashWalletTemp ==
                                              cashWalletController.text &&
                                          cardNameHolderTemp ==
                                              cardHolderNameController.text) {
                                        isDataChanged = false;
                                      }
                                    }
                                  },
                                ),
                                MyTextField(
                                  controller: cashWalletController,
                                  text: 'Cash Wallet',
                                  readOnly: widget.userModel.id != thisUserId,
                                  labelColor: Colors.black,
                                  onChanged: (value) {
                                    if (cashWalletTemp != value) {
                                      isDataChanged = true;
                                    } else {
                                      if (instapayLinkTemp ==
                                              instapayLinkController.text &&
                                          cardNameHolderTemp ==
                                              cardHolderNameController.text) {
                                        isDataChanged = false;
                                      }
                                    }
                                  },
                                ),
                                MyTextField(
                                  controller: cardHolderNameController,
                                  text: 'Card Holder Name',
                                  readOnly: widget.userModel.id != thisUserId,
                                  labelColor: Colors.black,
                                  onChanged: (value) {
                                    if (cardNameHolderTemp != value) {
                                      isDataChanged = true;
                                    } else {
                                      if (cashWalletTemp ==
                                              cashWalletController.text &&
                                          instapayLinkTemp ==
                                              instapayLinkController.text) {
                                        isDataChanged = false;
                                      }
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(right: screenWidth * 0.5),
                                  child: SubContainer(
                                    height: screenHeight * 0.05,
                                    title: Text(
                                      'Password',
                                      style: Styles.style14WhiteBold,
                                    ),
                                    colors: const [
                                      appColorLight1,
                                      appColorLight2
                                    ],
                                  ),
                                ),
                                widget.userModel.id == thisUserId
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: screenHeight * 0.01,
                                          ),
                                          MyTextField(
                                            controller: oldPasswordController,
                                            text: 'Old Password',
                                            isObsecure: true,
                                            fieldType: 'password',
                                            labelColor: Colors.black,
                                            onChanged: (value) {
                                              if (value != '') {
                                                isDataChanged = true;
                                              } else {
                                                if (cashWalletTemp ==
                                                        cashWalletController
                                                            .text &&
                                                    instapayLinkTemp ==
                                                        instapayLinkController
                                                            .text &&
                                                    cardNameHolderTemp ==
                                                        cardHolderNameController
                                                            .text) {
                                                  isDataChanged = false;
                                                }
                                              }
                                            },
                                          ),
                                          MyTextField(
                                            controller: newPasswordController,
                                            text: 'New Password',
                                            isObsecure: true,
                                            fieldType: 'password',
                                            labelColor: Colors.black,
                                            onChanged: (value) {
                                              if (value != '') {
                                                isDataChanged = true;
                                              } else {
                                                if (cashWalletTemp ==
                                                        cashWalletController
                                                            .text &&
                                                    instapayLinkTemp ==
                                                        instapayLinkController
                                                            .text &&
                                                    cardNameHolderTemp ==
                                                        cardHolderNameController
                                                            .text) {
                                                  isDataChanged = false;
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



  /*onTap: () async {
                  // النص الذي يحتوي على معلومات الدفع
                  String paymentInfo = widget.userModel.paymentInfo;

                  // تعبير منتظم لاستخراج الاسم بعد 'Card/VFCash:'
                  RegExp regex =
                      RegExp(r'Card/VFCash:\s*(\w+)', caseSensitive: false);
                  Match? match = regex.firstMatch(paymentInfo);

                  if (match != null) {
                    // استخراج الاسم من التعبير المنتظم
                    String userName = match.group(1) ?? '';

                    // بناء الرابط باستخدام الاسم المستخرج
                    String url = 'https://ipn.eg/S/$userName/instapay/4ckVQX';
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
                  } else {
                    print('Username not found in payment info');
                  }
                },*/
                    