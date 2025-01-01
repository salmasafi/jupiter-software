class BranchModel {
  String branch_Id;
  String branch_Name;
  String location;
  String city;
  String phone;
  String whatsApp;
  int employeesNo;
  int studentNo;

  BranchModel({
    required this.branch_Id,
    required this.branch_Name,
    required this.location,
    required this.city,
    required this.phone,
    required this.whatsApp,
    required this.employeesNo,
    required this.studentNo,
  });

  factory BranchModel.fromJson(json) {
    return BranchModel(
      branch_Id: json['branch_Id'] ?? '',
      branch_Name: json['branch_Name'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      whatsApp: json['whatsApp'] ?? '',
      employeesNo: json['employeesNo'] ?? 0,
      studentNo: json['studentNo'] ?? 0,
    );
  }
}
