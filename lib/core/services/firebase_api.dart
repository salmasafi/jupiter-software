import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/variables.dart';

class FirebaseApi {
  static DocumentReference getEmployeeDocForToday({required String id}) {
    DocumentReference employeeDoc = FirebaseFirestore.instance
        .collection(employeesDoc)
        .doc(id)
        .collection('CheckInOuts')
        .doc(DateFormat('MMMM yyyy').format(DateTime.now()))
        .collection('Dates')
        .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()));

    return employeeDoc;
  }

  static Future<DocumentSnapshot> getEmployeeSnapshotForToday(
      {required String id}) async {
    DocumentSnapshot employeeSnapshot =
        await FirebaseApi.getEmployeeDocForToday(id: id).get();
    return employeeSnapshot;
  }

  static DocumentReference getEmployeeDoc({required String id}) {
    DocumentReference employeeDoc =
        FirebaseFirestore.instance.collection(employeesDoc).doc(id);

    return employeeDoc;
  }

  static Future<DocumentSnapshot> getEmployeeSnapshot(
      {required String id}) async {
    DocumentSnapshot employeeSnapshot =
        await FirebaseApi.getEmployeeDoc(id: id).get();
    return employeeSnapshot;
  }

  static DocumentReference getEmployeeDocForThisMonth({required String id}) {
    DocumentReference employeeDoc = FirebaseFirestore.instance
        .collection(employeesDoc)
        .doc(id)
        .collection('CheckInOuts')
        .doc(DateFormat('MMMM yyyy').format(DateTime.now()));

    return employeeDoc;
  }

  static Future<DocumentSnapshot> getEmployeeSnapshotForThisMonth(
      {required String id}) async {
    DocumentSnapshot employeeSnapshot =
        await FirebaseApi.getEmployeeDocForThisMonth(id: id).get();
    return employeeSnapshot;
  }

  static DocumentReference getManagerDoc() {
    DocumentReference employeeDoc =
        FirebaseFirestore.instance.collection(employeesDoc).doc(
              employeesDoc == 'AsafraEmployees' ? shaimaaId : amiraId,
            );

    return employeeDoc;
  }

  static Future<DocumentSnapshot> getManagerSnapshot() async {
    DocumentSnapshot employeeSnapshot = await FirebaseApi.getManagerDoc().get();
    return employeeSnapshot;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getMonthsSnapshot(
      {required String id}) async {
    var monthsSnapshot = await FirebaseFirestore.instance
        .collection(employeesDoc)
        .doc(id)
        .collection('CheckInOuts')
        .get();
    return monthsSnapshot;
  }

  static Future<QuerySnapshot> getCheckInOutsForThisMonthSnapshot({
    required String id,
    required String month,
  }) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(employeesDoc)
        .doc(id)
        .collection('CheckInOuts')
        .doc(month)
        .collection('Dates')
        .get();
    return snapshot;
  }

  static Future<QuerySnapshot> getEmployeesSnapshot() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(employeesDoc).get();
    return snapshot;
  }

  static DocumentReference getEmployeeDocForSpecificDay({
    required String id,
    required String month,
    required String date,
  }) {
    DocumentReference employeeDoc = FirebaseFirestore.instance
        .collection(employeesDoc)
        .doc(id)
        .collection('CheckInOuts')
        .doc(month)
        .collection('Dates')
        .doc(date);

    return employeeDoc;
  }

  static DocumentReference getBranchDoc({required String branch}) {
    DocumentReference branchDoc =
        FirebaseFirestore.instance.collection('branches').doc(branch);

    return branchDoc;
  }

  static DocumentReference getEmployeeDocForSpecificMonth(
      {required String id, required String month}) {
    DocumentReference employeeDoc = FirebaseFirestore.instance
        .collection(employeesDoc)
        .doc(id)
        .collection('CheckInOuts')
        .doc(month);

    return employeeDoc;
  }

  static Future<DocumentSnapshot> getEmployeeSnapshotForSpecificMonth(
      {required String id, required String month}) async {
    DocumentSnapshot employeeSnapshot =
        await FirebaseApi.getEmployeeDocForSpecificMonth(id: id, month: month)
            .get();
    return employeeSnapshot;
  }

 static Future<QuerySnapshot> getMonthsforRequests() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .get();
    return snapshot;
  }

  static Future<QuerySnapshot> getRequestsForMonth(String month) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .doc(month)
        .collection('requests')
        .get();
    return snapshot;
  }
}
