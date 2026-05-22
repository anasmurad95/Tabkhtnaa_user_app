import 'package:flutter/foundation.dart';

import '../../data/orders_repository.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._repo);

  final OrdersRepository _repo;

  bool loading = false;
  String? error;
  List<Map<String, dynamic>> orders = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      orders = await _repo.listOrders();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}
