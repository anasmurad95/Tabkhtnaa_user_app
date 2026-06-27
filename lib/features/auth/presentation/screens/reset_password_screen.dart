import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/password_reset_session.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_reset_scaffold.dart';
import 'login_screen.dart';

/// Figma — ادخال كلمة مرور جديدة (step 3/3)
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.session});

  final PasswordResetSession session;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<AuthProvider>().completePasswordReset(
          session: widget.session,
          newPassword: _password.text,
          newPasswordConfirmation: _confirm.text,
        );

    if (!mounted) return;

    if (!ok) {
      AppToast.error(
        context,
        context.read<AuthProvider>().error ??
            context.tr('reset_password_failed', fallback: 'تعذر تحديث كلمة المرور'),
      );
      return;
    }

    AppToast.success(
      context,
      context.tr('reset_password_success', fallback: 'تم تحديث كلمة المرور بنجاح'),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PasswordResetScaffold(
      step: 2,
      title: context.tr('new_password_title', fallback: 'ادخال كلمة مرور جديدة'),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr(
                'new_password_hint',
                fallback:
                    'الرجاء ادخال كلمة مرور جديدة مكونة من 6 أحرف وأرقام ورموز متنوعة',
              ),
              textAlign: TextAlign.center,
              style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            _PasswordField(
              label: context.tr('new_password', fallback: 'كلمة المرور الجديدة'),
              controller: _password,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return context.tr('password_min_length', fallback: '6 أحرف على الأقل');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _PasswordField(
              label: context.tr('confirm_new_password', fallback: 'اعادة كتابة كلمة المرور'),
              controller: _confirm,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) {
                if (v != _password.text) {
                  return context.tr('password_mismatch', fallback: 'كلمتا المرور غير متطابقتين');
                }
                return null;
              },
            ),
            const Spacer(),
            PasswordResetPrimaryButton(
              label: context.tr('confirm_password', fallback: 'تأكيد الكلمة'),
              loading: auth.loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: AppTypography.shamelBook(size: 12),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: AppTypography.shamelBook(size: 12, color: AppColors.textHint),
        prefixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.iconMuted,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
