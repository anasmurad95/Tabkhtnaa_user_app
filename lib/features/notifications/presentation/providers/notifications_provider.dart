import 'package:flutter/foundation.dart';

import '../../data/models/notification_model.dart';
import '../../data/notifications_repository.dart';

enum NotificationTab { orders, admin }

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider(this._repo);

  final NotificationsRepository _repo;

  bool loading = false;
  String? error;
  List<NotificationModel> items = [];
  NotificationTab tab = NotificationTab.orders;

  List<NotificationModel> get filteredItems {
    return items.where((n) {
      return tab == NotificationTab.orders ? n.isOrderNotification : n.isAdminMessage;
    }).toList();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.list();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  void setTab(NotificationTab value) {
    if (tab == value) return;
    tab = value;
    notifyListeners();
  }

  Future<void> markSeen(int id) async {
    await _repo.markSeen(id);
    items = items
        .map((n) => n.id == id
            ? NotificationModel(
                id: n.id,
                title: n.title,
                body: n.body,
                orderId: n.orderId,
                data: n.data,
                seen: true,
                createdAt: n.createdAt,
              )
            : n)
        .toList();
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _repo.deleteAll();
    items = [];
    notifyListeners();
  }
}
