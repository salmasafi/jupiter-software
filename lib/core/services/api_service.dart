// ignore_for_file: unnecessary_string_interpolations, avoid_print

import 'package:dio/dio.dart';
import '../../features/batches/logic/models/student_model.dart';
import '../../features/branches/logic/models/branch_model.dart';
import '../../features/employees/logic/models/employee_model.dart';
import '../../features/batches/logic/models/batch_model.dart';
import '../../features/login/logic/models/user_model.dart';

class APiService {
  static String baseURL = 'https://api.jupitersoftware.net/api';

  Dio dio = Dio();

  Future<UserModel> getUserById(String id) async {
    Response response = await dio.get('$baseURL/User/$id');
    Map<String, dynamic> jsonData = response.data;

    return UserModel.fromJson(jsonData);
  }

  Future<String> getUserIdByLogin(String email, String password) async {
    Response response = await dio.post(
      '$baseURL/User/login',
      data: {
        "email": "$email",
        "password": "$password",
      },
    );
    Map<String, dynamic> json = response.data;

    if ((response.statusCode ?? 400) >= 200 &&
        (response.statusCode ?? 400) < 300) {
      return json['user_id'];
    } else {
      return 'Not Found';
    }
  }

  Future<String> changePassword(
    String id,
    String oldPassword,
    String newPassword,
  ) async {
    Response response = await dio.post(
      '$baseURL/User/changepassword/$id',
      data: {
        "oldPassword": "$oldPassword",
        "newPassword": "$newPassword",
      },
    );

    if ((response.statusCode ?? 400) >= 200 &&
        (response.statusCode ?? 400) < 300) {
      return 'Done';
    } else {
      return 'Error';
    }
  }

  Future<List<BatchModel>> getBatchById(String id) async {
    List<BatchModel> batchesList = [];
    Response response = await dio.get('$baseURL/Batches/instructor/$id');

    print('Response data: ${response.data}');

    Map<String, dynamic> jsonData = response.data;
    List batches = jsonData['data'];
    for (var batch in batches) {
      batchesList.add(BatchModel.fromJson(batch));
    }
    return batchesList;
  }

  Future<List<StudentModel>> getStudentsByBatchId(String id) async {
    List<StudentModel> studentsList = [];
    Response response =
        await dio.get('$baseURL/Enrollments/patch-students/$id');

    List jsonData = response.data;
    for (var student in jsonData) {
      studentsList.add(StudentModel.fromJson(student));
    }
    return studentsList;
  }

  Future<String> getUserImageById(String id) async {
    Response response = await dio.get('$baseURL/User/$id');
    Map<String, dynamic> jsonData = response.data;

    return jsonData['profileImagePath'];
  }

  Future<List<Employee>> getEmployees({required String branch}) async {
    try {
      final dio = Dio();
      final response = await dio.get('$baseURL/User/Employee');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<Employee> fetchedEmployees = [];

        for (var e in data) {
          if (e['branch'] == branch) {
            if (e['role'] != 'manager' &&
                e['role'] != 'Manager' &&
                e['isActive'] != false) {
              fetchedEmployees.add(
                Employee.fromJson(e),
              );

              print(e['profileImagePath']);
            }
          }
        }

        return fetchedEmployees;
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  Future<void> addABatch(BatchModel batchModel) async {
    Response response = await dio.post(
      '$baseURL/Batches',
      data: {
        "course_Id": "${batchModel.course_Id}",
        "startingTime": "${batchModel.startingTime}",
        "instructor_Id": "${batchModel.id}",
        "session_Day": "${batchModel.session_Day}",
        "session_Time": "${batchModel.session_Time}",
        "whatsAppChannel": "${batchModel.whatsAppChannel}",
        "batchType": "${batchModel.batch_Id}"
      },
    );

    if ((response.statusCode ?? 400) >= 200 &&
        (response.statusCode ?? 400) < 300) {
      print('Batch has added successfully');
    } else {
      print('Batch adding failed');
    }
  }

  Future<Response> changeProfileDetails({
    required UserModel userModel,
    String? role,
    String? address,
    String? email,
    String? whatsApp,
    String? phoneNumber,
    String? paymentInfo,
    String? branch,
    String? instapayLink,
    String? cashWallet,
    String? cardHolderName,
  }) async {
    Response response = await dio.put('$baseURL/User/${userModel.id}', data: {
      "id": userModel.id,
      "name": userModel.name,
      "role": role ?? userModel.role,
      "isActive": userModel.isActive,
      "address": address ?? userModel.address,
      "email": email ?? userModel.email,
      "whatsApp": whatsApp ?? userModel.whatsApp,
      "basicSalary": 0,
      "phoneNumber": phoneNumber ?? userModel.phoneNumber,
      "getStartedAt": userModel.getStartedAt,
      "profileImagePath": userModel.profileImagePath,
      "paymentInfo": paymentInfo ?? userModel.paymentInfo,
      "branch": branch ?? userModel.branch,
      "instapayLink": instapayLink ?? userModel.instapayLink,
      "cashWallet": cashWallet ?? userModel.cashWallet,
      "cardHolderName": cardHolderName ?? userModel.cardHolderName,
    });

    return response;
  }

  Future<bool> changePaymentInfo({
    required UserModel userModel,
    required String instapayLink,
    required String cashWallet,
    required String cardHolderName,
  }) async {
    
    // ignore: unused_local_variable
    Response? response;

    try {
      response = await APiService().changeProfileDetails(
        userModel: userModel,
        instapayLink: instapayLink,
        cashWallet: cashWallet,
        cardHolderName: cardHolderName,
      );
    } catch (e) {
      print('errrrrrrrrrrrrorrrrrrrrrrrr $e');
      return false;
    }

    return true;
  }

  Future<List<BranchModel>> getBranches() async {
    List<BranchModel> branchesList = [];
    Response response = await dio.get('$baseURL/Branches');

    print('Response data: ${response.data}');

    Map<String, dynamic> jsonData = response.data;
    List batches = jsonData['data'];
    for (var batch in batches) {
      branchesList.add(BranchModel.fromJson(batch));
    }
    return branchesList;
  }

  Future<bool> editABranch(BranchModel branchModel) async {
    Response response = await dio.put(
      '$baseURL/Branches/${branchModel.branch_Id}',
      data: {
        "branch_Id": "${branchModel.branch_Id}",
        "branch_Name": "${branchModel.branch_Name}",
        "location": "${branchModel.location}",
        "city": "${branchModel.city}",
        "phone": "${branchModel.phone}",
        "whatsApp": "${branchModel.whatsApp}",
        "employeesNo": branchModel.employeesNo,
        "studentsNo": branchModel.studentNo,
      },
    );

    print('status code is ${response.statusCode}');

    if ((response.statusCode ?? 400) >= 200 &&
        (response.statusCode ?? 400) < 300) {
      print('Branch has edited successfully');
      return true;
    } else {
      print('Branch editing failed');
      return false;
    }
  }
}

/* Map<String, String> employeesIds = {
  'Mohamed Elsayed': '17235db5-6a36-4248-88ff-b29a11fe2024',
  'Rawan Magdy': '25194165-f2f3-4032-a621-3e0b1dc5adc3',
  'Mariam Galal': '2f9bdd87-367b-45c4-b384-77a205dc3f69',
  'Ahmad Fathy': '3904e335-fcab-49ce-bf55-3195f7d998c1',
  'Omar Eslam': '59016b5c-a17f-4918-9007-5e9aafc7cc51',
  'Amira Gomaa': '670b2538-9ff7-414d-9f21-dbe7b6bfa8a9',
  'Taghred Ali': '71fd5c38-35c1-4036-bbf7-8982139a1e84',
  'Yara Ibrahim': 'a54c334c-ba55-4f23-a213-9915c93426ae',
  'Salma Safi': 'd666da61-11ed-48d2-bee7-f994d85e6be0',
  'Eman Mohamed': 'dd5b0c4d-cf64-435f-a635-17a3e61b185e',
  'Mahmoud Mohamed': 'e48f4f73-363e-4d50-8463-f49c1a2a2a40',
}; */
