import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/complaint_model.dart';
import '../../data/models/sanction_model.dart';
import '../../data/support_repository.dart';

enum SupportTab { complaints, penalties }

class SupportProvider extends ChangeNotifier {
  SupportProvider(this._repo);

  final SupportRepository _repo;

  bool loading = false;
  bool submitting = false;
  String? error;
  SupportTab tab = SupportTab.complaints;
  List<ComplaintModel> complaints = [];
  List<SanctionModel> sanctions = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.listComplaints(),
        _repo.listSanctions(),
      ]);
      complaints = results[0] as List<ComplaintModel>;
      sanctions = results[1] as List<SanctionModel>;
    } catch (e) {
      error = _formatError(e);
    }
    loading = false;
    notifyListeners();
  }

  void setTab(SupportTab value) {
    if (tab == value) return;
    tab = value;
    notifyListeners();
  }

  Future<bool> submitComplaint({
    required String type,
    required int orderId,
    required String title,
    required String details,
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _repo.createComplaint(
        type: type,
        orderId: orderId,
        description: details,
        note: title,
      );
      submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = _formatError(e);
      submitting = false;
      notifyListeners();
      return false;
    }
  }

  String _formatError(Object e) {
    if (e is ApiException) {
      if (e.statusCode == 500) {
        return 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
      }
      if (e.message.isNotEmpty && e.message != 'Network error') {
        return e.message;
      }
    }
    if (e is DioException && e.error is ApiException) {
      return _formatError(e.error as ApiException);
    }
    return 'تعذر إرسال الشكوى، يرجى المحاولة مرة أخرى';
  }

  Future<void> markSanctionSeen(int id) async {
    try {
      await _repo.markSanctionSeen(id);
      sanctions = sanctions
          .map((s) => s.id == id
              ? SanctionModel(
                  id: s.id,
                  type: s.type,
                  note: s.note,
                  seen: 'seen',
                  startTime: s.startTime,
                  endTime: s.endTime,
                  createdAt: s.createdAt,
                )
              : s)
          .toList();
      notifyListeners();
    } catch (e) {
      error = _formatError(e);
      notifyListeners();
      rethrow;
    }
  }
}
