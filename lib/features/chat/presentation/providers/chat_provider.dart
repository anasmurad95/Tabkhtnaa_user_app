import 'package:flutter/foundation.dart';

import '../../data/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._repo);

  final ChatRepository _repo;

  bool loading = false;
  String? error;
  List<Map<String, dynamic>> conversations = [];

  Future<void> loadConversations() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      conversations = await _repo.listConversations();
    } catch (e) {
      error = e.toString();
      conversations = [];
    }
    loading = false;
    notifyListeners();
  }
}
