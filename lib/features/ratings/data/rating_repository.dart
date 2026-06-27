import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';

class RatingRepository {
  RatingRepository(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> listChefRatings(int chefId) async {
    final res = await _client.dio.get('/user/rating/list', queryParameters: {'chef_id': chefId});
    return _parsePaginated(res.data);
  }

  Future<void> submitRating({
    required int chefId,
    required int orderId,
    int? ratingChef,
    int? ratingDelivery,
    int? ratingSpeedChef,
    String? note,
  }) async {
    final res = await _client.dio.post('/user/rating/create', data: {
      'chef_id': chefId,
      'order_id': orderId,
      if (ratingChef != null) 'rating_chef': ratingChef,
      if (ratingDelivery != null) 'rating_delivery': ratingDelivery,
      if (ratingSpeedChef != null) 'rating_speed_chef': ratingSpeedChef,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Rating failed');
    }
  }

  List<Map<String, dynamic>> _parsePaginated(dynamic raw) {
    if (raw is! Map<String, dynamic> || raw['status'] != true) {
      throw ApiException(raw is Map ? raw['error_msg']?.toString() ?? 'Failed' : 'Failed');
    }
    final data = raw['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}
