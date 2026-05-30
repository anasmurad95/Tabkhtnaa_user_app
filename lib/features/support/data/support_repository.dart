import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import 'models/complaint_model.dart';
import 'models/sanction_model.dart';

/// Maps UI complaint categories to API enum values.
String mapComplaintTypeToApi(String uiType) {
  switch (uiType) {
    case 'delivery':
      return 'driver';
    case 'payment':
      return 'management';
    case 'other':
      return 'user';
    case 'maker':
    case 'driver':
    case 'management':
    case 'user':
      return uiType;
    default:
      return 'maker';
  }
}

class SupportRepository {
  SupportRepository(this._client);

  final ApiClient _client;

  Future<List<ComplaintModel>> listComplaints() async {
    final res = await _client.dio.get('/complaint/list');
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Failed');
    }
    final data = parsed.data;
    if (data is List) {
      return data.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ComplaintModel> createComplaint({
    required String type,
    required int orderId,
    required String description,
    required String note,
  }) async {
    try {
      final res = await _client.dio.post('/complaint/create', data: {
        'type': mapComplaintTypeToApi(type),
        'order_id': orderId,
        'description': description,
        'note': note,
      });
      final parsed = ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        parser: (v) => ComplaintModel.fromJson(v as Map<String, dynamic>),
      );
      if (!parsed.status || parsed.data == null) {
        throw ApiException(parsed.errorMsg ?? 'تعذر إرسال الشكوى');
      }
      return parsed.data!;
    } on DioException catch (e) {
      throw _toApiException(e, fallback: 'تعذر إرسال الشكوى');
    }
  }

  ApiException _toApiException(DioException e, {required String fallback}) {
    final wrapped = e.error;
    if (wrapped is ApiException) return wrapped;
    final status = e.response?.statusCode;
    if (status == 500) {
      return ApiException('حدث خطأ في الخادم، يرجى المحاولة لاحقاً', statusCode: status);
    }
    return ApiException(fallback, statusCode: status);
  }

  Future<List<SanctionModel>> listSanctions() async {
    final res = await _client.dio.get('/user/sanction/list');
    return _parsePaginated(res.data, SanctionModel.fromJson);
  }

  Future<void> markSanctionSeen(int id) async {
    final res = await _client.dio.get('/user/sanction/seen', queryParameters: {'id': id});
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
