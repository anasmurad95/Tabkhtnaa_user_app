import '../../../../core/utils/json_parse.dart';

class ComplaintModel {
  final int id;
  final int? orderId;
  final String? type;
  final String? description;
  final String? status;
  final String? note;
  final DateTime? createdAt;

  const ComplaintModel({
    required this.id,
    this.orderId,
    this.type,
    this.description,
    this.status,
    this.note,
    this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: parseJsonInt(json['id']),
      orderId: parseJsonIntOrNull(json['order_id']),
      type: json['type']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
