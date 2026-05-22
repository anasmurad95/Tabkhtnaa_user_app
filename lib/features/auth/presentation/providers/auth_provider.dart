import 'package:flutter/foundation.dart';

import '../../data/auth_repository.dart';
import '../../data/models/user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  String? error;
  bool loading = false;

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    user = await _repository.loadCachedUser();
    status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    loading = false;
    notifyListeners();
  }

  Future<bool> login({
    required String countryCode,
    required String mobile,
    required String password,
  }) async {
    return _run(() async {
      user = await _repository.login(
        countryCode: countryCode,
        mobile: mobile,
        password: password,
      );
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> register(dynamic formData) async {
    return _run(() async {
      user = await _repository.register(formData);
      status = AuthStatus.authenticated;
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
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
      error = e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
