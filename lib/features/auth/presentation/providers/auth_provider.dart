import 'package:flutter/foundation.dart';

import '../../data/auth_repository.dart';
import '../../data/models/password_reset_session.dart';
import '../../data/models/register_session.dart';
import '../../data/models/user_model.dart';
import '../../../../core/network/api_exception.dart';

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

  Future<PasswordResetSession?> requestPasswordReset({
    required String countryCode,
    required String mobile,
  }) async {
    PasswordResetSession? session;
    final ok = await _run(() async {
      session = await _repository.forgetPassword(countryCode: countryCode, mobile: mobile);
    });
    return ok ? session : null;
  }

  Future<RegisterSession?> sendRegistrationSms() async {
    RegisterSession? session;
    final ok = await _run(() async {
      final data = await _repository.sendSms();
      session = RegisterSession.fromSmsResponse(
        countryCode: user?.countryCode ?? '962',
        mobile: user?.mobile ?? '',
        userJson: data,
      );
    });
    return ok ? session : null;
  }

  Future<bool> verifyRegistrationOtp(String code, RegisterSession session) async {
    if (code != session.smsVerifyCode) {
      error = 'رمز التحقق غير صحيح';
      notifyListeners();
      return false;
    }
    final userId = user?.id;
    if (userId == null) {
      error = 'المستخدم غير موجود';
      notifyListeners();
      return false;
    }
    return _run(() async {
      user = await _repository.verifyMobile(userId: userId);
    });
  }

  Future<String?> loadTermsAndConditions() async {
    String? terms;
    final ok = await _run(() async {
      terms = await _repository.fetchTermsAndConditions();
    });
    return ok ? terms : null;
  }

  Future<bool> completePasswordReset({
    required PasswordResetSession session,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return _run(() async {
      await _repository.resetPassword(
        userId: session.userId,
        resetToken: session.resetToken,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void syncUser(UserModel updated) {
    user = updated;
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
      error = e is ApiException ? e.message : e.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
