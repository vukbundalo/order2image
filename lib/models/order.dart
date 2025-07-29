class OrderModel {
  final String orderId;
  final String patientId;
  final String patientName;
  final String procedureCode;
  final String orderDateTime;

  OrderModel({
    required this.orderId,
    required this.patientId,
    required this.patientName,
    required this.procedureCode,
    required this.orderDateTime,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['OrderID'],
      patientId: map['PatientID'],
      patientName: '${map['FirstName']} ${map['LastName']}',
      procedureCode: map['ProcedureCode'],
      orderDateTime: map['OrderDateTime'],
    );
  }
}
