import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/password_reset_session.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import '../widgets/otp_input_widgets.dart';
import '../widgets/password_reset_scaffold.dart';
import 'reset_password_screen.dart';

/// Figma — ادخال رقم التأكيد (step 2/3)
class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key, required this.session});

  final PasswordResetSession session;

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final _digits = <String>[];

  String get _code => _digits.join();

  void _onDigit(String d) {
    if (_digits.length >= 4) return;
    setState(() => _digits.add(d));
  }

  void _onBackspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  void _confirm() {
    if (_code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('otp_required', fallback: 'أدخل الرمز المكون من 4 أرقام')),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(session: widget.session),
      ),
    );
  }

  Future<void> _resend() async {
    final session = await context.read<AuthProvider>().requestPasswordReset(
          countryCode: widget.session.countryCode,
          mobile: widget.session.mobile,
        );
    if (!mounted) return;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthProvider>().error ??
                context.tr('resend_failed', fallback: 'تعذر إعادة الإرسال'),
          ),
        ),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordOtpScreen(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PasswordResetScaffold(
      step: 1,
      title: context.tr('enter_confirmation_code', fallback: 'ادخال رقم التأكيد'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr(
              'otp_sms_hint',
              fallback: 'سيتم ارسال رسالة الى هاتفك مكونة من 4 ارقام عبر رسائل الجوال',
            ),
            textAlign: TextAlign.center,
            style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 28),
          OtpCircles(filledCount: _digits.length),
          const SizedBox(height: 24),
          Expanded(child: NumericKeypad(onDigit: _onDigit, onBackspace: _onBackspace)),
          PasswordResetPrimaryButton(
            label: context.tr('confirm_account', fallback: 'تأكيد الحساب'),
            loading: auth.loading,
            onPressed: _confirm,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                context.tr('otp_not_received', fallback: 'لم تصلك الكلمة، '),
                style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
              ),
              GestureDetector(
                onTap: auth.loading ? null : _resend,
                child: Text(
                  context.tr('resend_password_link', fallback: 'اعادة ارسال كلمة السر'),
                  style: AppTypography.shamelBold(size: 10, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
