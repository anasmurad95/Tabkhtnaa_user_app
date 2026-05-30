import '../../../../core/utils/json_parse.dart';

class NotificationModel {
  final int id;
  final String? title;
  final String? body;
  final String? orderId;
  final Map<String, dynamic>? data;
  final bool seen;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    this.title,
    this.body,
    this.orderId,
    this.data,
    this.seen = false,
    this.createdAt,
  });

  bool get isOrderNotification =>
      orderId != null && orderId!.isNotEmpty && orderId != '0';

  bool get isAdminMessage => !isOrderNotification;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    Map<String, dynamic>? parsedData;
    if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        // ignore: avoid_dynamic_calls
        parsedData = null;
      } catch (_) {}
    }

    return NotificationModel(
      id: parseJsonInt(json['id']),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      orderId: json['order_id']?.toString(),
      data: parsedData,
      seen: json['seen'] == true || json['seen'] == 1 || json['seen'] == '1',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
