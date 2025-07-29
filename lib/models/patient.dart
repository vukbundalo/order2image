class Patient {
  final String patientID;
  final String mrn;
  final String firstName;
  final String lastName;
  final String dob;
  final String gender;
  final String allergies;

  Patient({
    required this.patientID,
    required this.mrn,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.allergies,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientID: map['PatientID'],
      mrn: map['MRN'],
      firstName: map['FirstName'],
      lastName: map['LastName'],
      dob: map['DOB'],
      gender: map['Gender'],
      allergies: map['Allergies'],
    );
  }
}
