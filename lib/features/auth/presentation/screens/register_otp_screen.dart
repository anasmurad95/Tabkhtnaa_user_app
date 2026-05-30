import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/register_session.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import '../widgets/otp_input_widgets.dart';
import '../widgets/password_reset_scaffold.dart';
import '../widgets/register_continue_dialog.dart';
import 'register_address_screen.dart';

/// Flow A step 2 — ادخال رقم التأكيد
class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key, required this.session});

  final RegisterSession session;

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
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

  Future<void> _confirm() async {
    if (_code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('otp_required', fallback: 'أدخل الرمز المكون من 4 أرقام')),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyRegistrationOtp(_code, widget.session);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? context.tr('otp_invalid', fallback: 'رمز غير صحيح'))),
      );
      return;
    }

    await showRegisterContinueDialog(
      context,
      onContinue: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterAddressScreen()),
        );
      },
      onExit: () async {
        await auth.logout();
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final session = await auth.sendRegistrationSms();
    if (!mounted) return;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? context.tr('resend_failed', fallback: 'تعذر إعادة الإرسال'))),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RegisterOtpScreen(session: session)),
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
                  context.tr('resend_code', fallback: 'اعادة ارسال الرمز'),
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
