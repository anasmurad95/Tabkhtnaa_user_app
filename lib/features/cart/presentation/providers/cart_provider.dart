import 'package:flutter/foundation.dart';

import '../../data/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._repo);

  final CartRepository _repo;

  bool loading = false;
  String? error;
  Map<String, dynamic>? cart;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      cart = await _repo.getCart();
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
  }) async {
    loading = true;
    notifyListeners();
    try {
      cart = await _repo.addToCart(
        makerId: makerId,
        mealId: mealId,
        quantity: quantity,
        note: note,
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

  Future<void> updateQty(int itemId, int qty) async {
    cart = await _repo.updateQuantity(cartItemId: itemId, quantity: qty);
    notifyListeners();
  }

  Future<void> remove(int itemId) async {
    cart = await _repo.deleteItem(itemId);
    notifyListeners();
  }
}
