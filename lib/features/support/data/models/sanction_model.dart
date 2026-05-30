import '../../../../core/utils/json_parse.dart';

class SanctionModel {
  final int id;
  final String? type;
  final String? note;
  final String? seen;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? createdAt;

  const SanctionModel({
    required this.id,
    this.type,
    this.note,
    this.seen,
    this.startTime,
    this.endTime,
    this.createdAt,
  });

  bool get isNew => seen == null || seen == 'unseen' || seen == '0';

  factory SanctionModel.fromJson(Map<String, dynamic> json) {
    return SanctionModel(
      id: parseJsonInt(json['id']),
      type: json['type']?.toString(),
      note: json['note']?.toString(),
      seen: json['seen']?.toString(),
      startTime: DateTime.tryParse(json['start_time']?.toString() ?? ''),
      endTime: DateTime.tryParse(json['end_time']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
