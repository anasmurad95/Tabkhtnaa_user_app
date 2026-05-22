import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart' show FigmaAuthScaffold;
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

/// Figma 0:4960, 0:4819, 0:4864, 0:4796 — Sign up flow
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _countryCode = TextEditingController(text: '+966');
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _dob = TextEditingController(text: '2000-01-01');
  String _gender = 'male';
  int? _countryId;
  XFile? _avatar;
  List<Map<String, dynamic>> _countries = [];
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCountries());
  }

  Future<void> _loadCountries() async {
    final client = context.read<ApiClient>();
    final res = await client.dio.get('/countries');
    final data = res.data['data'] as List?;
    if (data != null && mounted) {
      setState(() {
        _countries = data.cast<Map<String, dynamic>>();
        if (_countries.isNotEmpty) _countryId = _countries.first['id'] as int?;
      });
    }
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _avatar = img);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _avatar == null || _countryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('profile_image_required', fallback: 'الصورة والدولة مطلوبان'))),
      );
      return;
    }
    final form = FormData.fromMap({
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'mobile': _mobile.text.trim(),
      'country_code': _countryCode.text.trim(),
      'residence_country_id': _countryId,
      'dob': _dob.text.trim(),
      'gender': _gender,
      'type': 'client',
      'password': _password.text,
      'password_confirmation': _confirm.text,
      'profile_image': await MultipartFile.fromFile(_avatar!.path),
    });
    final ok = await context.read<AuthProvider>().register(form);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AuthProvider>().error ?? 'Register failed')),
      );
    } else if (ok && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(phoneOrEmail: _mobile.text)),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return FigmaAuthScaffold(
      hero: Image.asset(FigmaAssets.loginHeroHouse, width: 120, height: 120),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(43, 0, 43, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('sign_up', fallback: 'تسجيل حساب'),
                textAlign: TextAlign.center,
                style: AppTypography.shamelBold(size: 20, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: _avatar != null ? FileImage(File(_avatar!.path)) : null,
                    child: _avatar == null
                        ? Image.asset(FigmaAssets.loginUserGrey, width: 28, height: 28)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _field(_name, context.tr('full_name', fallback: 'الاسم'), FigmaAssets.loginUserGrey),
              const SizedBox(height: 12),
              _field(_email, context.tr('email', fallback: 'البريد'), FigmaAssets.loginUserGrey, keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 90, child: _field(_countryCode, '+', FigmaAssets.loginUserGrey, keyboard: TextInputType.phone)),
                  const SizedBox(width: 8),
                  Expanded(child: _field(_mobile, context.tr('mobile', fallback: 'الجوال'), FigmaAssets.loginUserGrey, keyboard: TextInputType.phone)),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _countryId,
                decoration: InputDecoration(labelText: context.tr('country', fallback: 'الدولة')),
                items: _countries
                    .map((c) => DropdownMenuItem(value: c['id'] as int, child: Text(c['name']?.toString() ?? '')))
                    .toList(),
                onChanged: (v) => setState(() => _countryId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(labelText: context.tr('gender', fallback: 'الجنس')),
                items: [
                  DropdownMenuItem(value: 'male', child: Text(context.tr('male', fallback: 'ذكر'))),
                  DropdownMenuItem(value: 'female', child: Text(context.tr('female', fallback: 'أنثى'))),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'male'),
              ),
              const SizedBox(height: 12),
              _field(_password, context.tr('password', fallback: 'كلمة المرور'), FigmaAssets.loginPasswordGrey, obscure: _obscure, onToggle: () => setState(() => _obscure = !_obscure)),
              const SizedBox(height: 12),
              _field(_confirm, context.tr('confirm_password', fallback: 'تأكيد كلمة المرور'), FigmaAssets.loginPasswordGrey, obscure: true),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : _submit,
                  child: auth.loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(context.tr('create_account', fallback: 'إنشاء حساب')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    String icon, {
    TextInputType? keyboard,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTypography.shamelBook(size: 10)),
        const SizedBox(height: 4),
        TextFormField(
          controller: c,
          obscureText: obscure,
          keyboardType: keyboard,
          validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
          decoration: InputDecoration(
            prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Image.asset(icon, width: 20, height: 20)),
            suffixIcon: onToggle != null
                ? IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18), onPressed: onToggle)
                : null,
          ),
        ),
      ],
    );
  }
}
