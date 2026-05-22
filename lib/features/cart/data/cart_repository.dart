import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';

class CartRepository {
  CartRepository(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getCart() async {
    final res = await _client.dio.get('/user/cart/list');
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Cart empty');
    }
    return parsed.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addToCart({
    required int makerId,
    required int mealId,
    required int quantity,
    List<int>? accessories,
    List<int>? additions,
    String? note,
  }) async {
    final res = await _client.dio.post('/user/cart/create', data: {
      'maker_id': makerId,
      'meal_id': mealId,
      'quantity': quantity,
      if (note != null) 'note': note,
      if (accessories != null) 'accessories': accessories,
      if (additions != null) 'additions': additions,
    });
    return _unwrap(res.data);
  }

  Future<Map<String, dynamic>> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final res = await _client.dio.post('/user/cart/update_quantity', data: {
      'cart_item_id': cartItemId,
      'quantity': quantity,
    });
    return _unwrap(res.data);
  }

  Future<Map<String, dynamic>> deleteItem(int cartItemId) async {
    final res = await _client.dio.post('/user/cart/delete_item', data: {
      'cart_item_id': cartItemId,
    });
    return _unwrap(res.data);
  }

  Future<void> clearCart() async {
    await _client.dio.post('/user/cart/delete_all');
  }

  Map<String, dynamic> _unwrap(dynamic raw) {
    final parsed = ApiResponse.fromJson(raw as Map<String, dynamic>);
    if (!parsed.status || parsed.data == null) {
      throw ApiException(parsed.errorMsg ?? 'Cart update failed');
    }
    return parsed.data as Map<String, dynamic>;
  }
}
