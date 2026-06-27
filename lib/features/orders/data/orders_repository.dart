import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';

class OrdersRepository {
  OrdersRepository(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> listOrders({String? status}) async {
    final res = await _client.dio.get('/user/orders/list', queryParameters: {
      if (status != null) 'status': status,
    });
    return _parsePaginated(res.data);
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    final res = await _client.dio.get('/user/orders/get', queryParameters: {'order_id': id});
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status || parsed.data == null) {
      throw ApiException(parsed.errorMsg ?? 'Order not found');
    }
    return parsed.data as Map<String, dynamic>;
  }

  Future<void> createOrder({
    required int chefId,
    required int cartId,
    required int addressId,
    required String paymentMethod,
    required String deliveryType,
    String? details,
  }) async {
    final res = await _client.dio.post('/user/orders/create', data: {
      'chef_id': chefId,
      'cart_id': cartId,
      'address_id': addressId,
      'payment_method': paymentMethod,
      'delivery_type': deliveryType,
      if (details != null) 'details': details,
    });
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Order failed');
    }
  }

  Future<void> cancelOrder(int orderId) async {
    final res = await _client.dio.post('/user/orders/cancel', data: {
      'order_id': orderId,
    });
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Cancel failed');
    }
  }

  List<Map<String, dynamic>> _parsePaginated(dynamic raw) {
    if (raw is! Map<String, dynamic> || raw['status'] != true) {
      throw ApiException(raw is Map ? raw['error_msg']?.toString() ?? 'Failed' : 'Failed');
    }
    final data = raw['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
