import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_reset_illustration.dart';
import '../widgets/password_reset_scaffold.dart';
import 'forgot_password_otp_screen.dart';

/// Figma — استعادة الكلمة السرية (step 1/3)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _phoneCountryCode = '962';
  String _mobile = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final session = await context.read<AuthProvider>().requestPasswordReset(
          countryCode: _phoneCountryCode,
          mobile: _mobile,
        );

    if (!mounted) return;

    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthProvider>().error ??
                context.tr('reset_request_failed', fallback: 'تعذر إرسال الطلب'),
          ),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordOtpScreen(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PasswordResetScaffold(
      step: 0,
      title: context.tr('reset_password_title', fallback: 'استعادة الكلمة السرية'),
      headerHero: const PasswordResetIllustration(size: 110),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.tr('phone_number', fallback: 'رقم الهاتف'),
                  style: AppTypography.shamelBook(size: 10, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: IntlPhoneField(
                    controller: _phoneController,
                    initialCountryCode: 'JO',
                    languageCode: 'ar',
                    showCountryFlag: !kIsWeb,
                    flagsButtonPadding: const EdgeInsetsDirectional.only(start: 4),
                    flagsButtonMargin: EdgeInsets.zero,
                    dropdownIcon: const Icon(Icons.arrow_drop_down, size: 18),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, maxWidth: 96),
                      hintText: context.tr('phone_number', fallback: 'رقم الهاتف'),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (phone) {
                      _phoneCountryCode = phone.countryCode;
                      _mobile = phone.number;
                    },
                    validator: (phone) {
                      if (phone == null || phone.number.isEmpty) {
                        return context.tr('required', fallback: 'مطلوب');
                      }
                      if (!phone.isValidNumber()) {
                        return context.tr('invalid_phone', fallback: 'رقم غير صالح');
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.tr(
                'reset_password_phone_hint',
                fallback:
                    'الرجاء تدوين رقم هاتفك المسجل لدينا، وسيتم ارسال مكونة من أربعة أرقام خلال دقائق.',
              ),
              textAlign: TextAlign.center,
              style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
            ),
            const Spacer(),
            PasswordResetPrimaryButton(
              label: context.tr('send', fallback: 'ارسال'),
              loading: auth.loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
