import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import 'models/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  Future<List<NotificationModel>> list() async {
    final res = await _client.dio.get('/notification/list');
    return _parsePaginated(res.data, NotificationModel.fromJson);
  }

  Future<void> markSeen(int notificationId) async {
    final res = await _client.dio.post('/notification/seen', data: {
      'notification_id': notificationId,
    });
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Failed to mark seen');
    }
  }

  Future<void> markAllSeen() async {
    final res = await _client.dio.post('/notification/seen_all');
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Failed');
    }
  }

  Future<void> deleteAll() async {
    final res = await _client.dio.post('/notification/delete_all');
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Failed');
    }
  }

  List<T> _parsePaginated<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! Map<String, dynamic>) return [];
    if (raw['status'] != true) {
      throw ApiException(raw['error_msg']?.toString() ?? 'Failed');
    }
    final data = raw['data'];
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
