import '../../../login/logic/models/user_model.dart';

class Employee extends UserModel {
  Employee({
    required super.name,
    required super.id,
    required super.role,
    required super.branch,
    required super.email,
    required super.phone,
    required super.whatsApp,
    required super.getStartedAt,
    required super.profileImagePath,
    required super.paymentInfo,
    required super.isActive,
    required super.phoneNumber,
    required super.basicSalary,
    required super.userName,
    required super.instapayLink,
    required super.cashWallet,
    required super.cardHolderName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      branch: json['branch'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      whatsApp: json['whatsApp'] ?? '',
      isActive: json['isActive'] ?? '',
      getStartedAt: json['getStartedAt'] ?? '',
      profileImagePath: json['profileImagePath'] ?? '',
      paymentInfo: json['paymentInfo'] ?? '',
      basicSalary: json['basicSalary'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userName: json['userName'] ?? '',
      instapayLink: json['instapayLink'] ?? '',
      cashWallet: json['cashWallet'] ?? '',
      cardHolderName: json['cardHolderName'] ?? '',
    );
  }
}
