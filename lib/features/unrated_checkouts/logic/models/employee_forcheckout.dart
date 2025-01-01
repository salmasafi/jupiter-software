class EmployeeForcheckout {
  String id;
  String name;

  EmployeeForcheckout(this.name, this.id);
}

class UnratedCheckOut {
  EmployeeForcheckout employeeForcheckout;
  List<Map<String, dynamic>?> checkInOuts;

  UnratedCheckOut(this.employeeForcheckout, this.checkInOuts);
}
