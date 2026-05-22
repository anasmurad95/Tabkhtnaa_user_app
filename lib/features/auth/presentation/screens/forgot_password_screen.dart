import 'package:flutter/material.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart' show FigmaAuthScaffold;
import '../../../localization/presentation/extensions/translation_context.dart';
import 'otp_verification_screen.dart';

/// Figma 0:4641, 0:4582 — reset password
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contact = TextEditingController();

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtpVerificationScreen(phoneOrEmail: _contact.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FigmaAuthScaffold(
      hero: Image.asset(FigmaAssets.loginHeroHouse, width: 100, height: 100),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(43, 16, 43, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('forgot_password', fallback: 'نسيت كلمة المرور ؟'),
                textAlign: TextAlign.center,
                style: AppTypography.shamelBold(size: 20, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('forgot_password_hint', fallback: 'أدخل بريدك أو رقم جوالك المرتبط بالحساب'),
                textAlign: TextAlign.center,
                style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _contact,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                decoration: InputDecoration(
                  labelText: context.tr('email_or_phone', fallback: 'بريد أو جوال'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(FigmaAssets.loginUserGrey, width: 20, height: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(context.tr('send_reset_code', fallback: 'إرسال رمز الاستعادة')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
