import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/database_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];

  List<OrderModel> get orders => _orders;

  Future<void> loadPendingOrders() async {
    final rows = await DatabaseService.instance.getPendingOrders();
    _orders = rows.map((row) => OrderModel.fromMap(row)).toList();
    notifyListeners();
  }

  void refresh() => loadPendingOrders();
}
