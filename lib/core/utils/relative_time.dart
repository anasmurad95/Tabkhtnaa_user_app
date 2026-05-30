import 'package:intl/intl.dart';

String formatRelativeTimeAr(DateTime? dateTime) {
  if (dateTime == null) return '';
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقائق';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
  return DateFormat('yyyy/MM/dd', 'ar').format(dateTime);
}
