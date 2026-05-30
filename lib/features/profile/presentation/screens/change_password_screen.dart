import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/widgets/password_reset_scaffold.dart';
import '../../../auth/presentation/widgets/register_form_field.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/profile_provider.dart';

/// Figma — تغيير كلمة السرية
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<ProfileProvider>();
    final ok = await profile.changePassword(
      currentPassword: _current.text,
      password: _password.text,
      passwordConfirmation: _confirm.text,
    );

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profile.error ??
                context.tr('change_password_failed', fallback: 'تعذر تغيير كلمة المرور'),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr('change_password_success', fallback: 'تم تغيير كلمة المرور'),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return AppPageScaffold(
      title: context.tr('change_password', fallback: 'تغيير كلمة السرية'),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RegisterFormField(
                label: context.tr('current_password', fallback: 'الباسورد الحالي'),
                controller: _current,
                iconAsset: FigmaAssets.loginPasswordGrey,
                obscure: _obscureCurrent,
                onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return context.tr('password_min_length', fallback: '6 أحرف على الأقل');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              RegisterFormField(
                label: context.tr('new_password', fallback: 'الباسورد الجديد'),
                controller: _password,
                iconAsset: FigmaAssets.loginPasswordGrey,
                obscure: _obscureNew,
                onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return context.tr('password_min_length', fallback: '6 أحرف على الأقل');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              RegisterFormField(
                label: context.tr('confirm_new_password', fallback: 'إعادة كتابة الباسورد الجديد'),
                controller: _confirm,
                iconAsset: FigmaAssets.loginPasswordGrey,
                obscure: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v != _password.text) {
                    return context.tr('password_mismatch', fallback: 'كلمتا المرور غير متطابقتين');
                  }
                  return null;
                },
              ),
              const Spacer(),
              PasswordResetPrimaryButton(
                label: context.tr('save', fallback: 'حفظ'),
                loading: profile.loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
