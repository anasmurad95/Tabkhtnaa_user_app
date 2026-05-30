import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository, this._auth);

  final ProfileRepository _repository;
  final AuthProvider _auth;

  bool loading = false;
  String? error;

  UserModel? get user => _auth.user;

  Future<bool> updateProfile(UserModel updated) async {
    return _run(() async {
      final saved = await _repository.updateProfile(updated.toUpdatePayload());
      _auth.syncUser(saved);
    });
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _run(() async {
      final saved = await _repository.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _auth.syncUser(saved);
    });
  }

  Future<bool> setOnline(bool online) async {
    return _run(() async {
      final status = online ? 'online' : 'unavailable';
      final saved = await _repository.updateOnlineStatus(status);
      _auth.syncUser(saved);
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e is ApiException ? e.message : e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
