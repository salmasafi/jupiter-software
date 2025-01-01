import 'package:flutter/material.dart';
import 'package:jupiter_academy/core/services/api_service.dart';
import 'package:jupiter_academy/core/utils/styles.dart';
import 'package:jupiter_academy/features/branches/logic/models/branch_model.dart';
import 'package:jupiter_academy/features/branches/presentation/views/edit_branch.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../../core/widgets/build_appbar_method.dart';
import '../../../../core/widgets/my_list_tile.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  bool inAsyncCall = true;
  List<BranchModel> branchesList = [];

  _getBranches() async {
    branchesList = await APiService().getBranches();
    setState(() {
      inAsyncCall = false;
    });
  }

  @override
  void initState() {
    _getBranches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: inAsyncCall,
      child: Scaffold(
        appBar: buildAppBar(),
        body: ListView.builder(
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MySquareTile(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        branchesList[index].branch_Name,
                        style: Styles.style24,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    flex: 1,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditBranch(
                                  branchModel: branchesList[index],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.location_city,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          itemCount: branchesList.length,
        ),
      ),
    );
  }
}
