import 'package:flutter/material.dart';
import '../models/audit.dart';
import '../services/database_service.dart';

class AuditProvider with ChangeNotifier {
  List<AuditEvent> _events = [];

  List<AuditEvent> get events => _events;

  Future<void> load() async {
    _events = await DatabaseService.instance.getAuditLog();
    notifyListeners();
  }

  void refresh() => load();
}
