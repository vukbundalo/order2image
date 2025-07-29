import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];
  Patient? _selectedPatient;

  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;

  Future<void> loadPatients() async {
    final data = await DatabaseService.instance.getAllPatients();
    _patients = data.map((row) => Patient.fromMap(row)).toList();
    notifyListeners();
  }

  void selectPatient(Patient patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPatient = null;
    notifyListeners();
  }

  bool get hasSelection => _selectedPatient != null;

}

