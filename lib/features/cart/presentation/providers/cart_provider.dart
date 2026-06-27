import 'package:flutter/foundation.dart';

import '../../data/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._repo);

  final CartRepository _repo;

  bool loading = false;
  String? error;
  Map<String, dynamic>? cart;

  Future<void> load({String? deliveryType}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      cart = await _repo.getCart(deliveryType: deliveryType);
    } catch (e) {
      cart = null;
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> add({
    required int makerId,
    required int mealId,
    int quantity = 1,
    String? note,
    List<int>? accessories,
    List<int>? additions,
  }) async {
    loading = true;
    notifyListeners();
    try {
      cart = await _repo.addToCart(
        makerId: makerId,
        mealId: mealId,
        quantity: quantity,
        note: note,
        accessories: accessories,
        additions: additions,
      );
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setAccessories(List<int> accessoryIds) async {
    try {
      cart = await _repo.setAccessories(accessoryIds);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> loadAccessories() => _repo.getAccessories();

  Future<void> updateQty(int itemId, int qty) async {
    try {
      cart = await _repo.updateQuantity(cartItemId: itemId, quantity: qty);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(int itemId) async {
    try {
      cart = await _repo.deleteItem(itemId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
