import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_reset_illustration.dart';
import '../widgets/password_reset_scaffold.dart';
import '../widgets/register_form_field.dart';
import 'register_otp_screen.dart';

/// Flow A step 1 — المعلومات الشخصية
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _dob = TextEditingController();
  final _phoneController = TextEditingController();

  String _gender = 'male';
  int? _residenceCountryId;
  String _phoneCountryCode = '962';
  String _mobile = '';
  bool _acceptedTerms = false;
  bool _obscure = true;
  List<Map<String, dynamic>> _countries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCountries());
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _dob.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    final client = context.read<ApiClient>();
    final res = await client.dio.get('/countries');
    final data = res.data['data'] as List?;
    if (data != null && mounted) {
      setState(() {
        _countries = data.cast<Map<String, dynamic>>();
        final jordan = _countries.cast<Map<String, dynamic>?>().firstWhere(
              (c) => c?['iso2']?.toString().toUpperCase() == 'JO',
              orElse: () => _countries.isNotEmpty ? _countries.first : null,
            );
        _residenceCountryId = jordan?['id'] as int? ?? (_countries.isNotEmpty ? _countries.first['id'] as int? : null);
      });
    }
  }

  String _countryLabel(Map<String, dynamic> country) {
    return country['native']?.toString() ??
        country['translations']?['ar']?.toString() ??
        country['iso2']?.toString() ??
        '';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      _dob.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  Future<MultipartFile> _defaultProfileImage() async {
    final data = await rootBundle.load(FigmaAssets.loginHeroHouse);
    return MultipartFile.fromBytes(data.buffer.asUint8List(), filename: 'profile.png');
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('accept_terms_required', fallback: 'يجب الموافقة على الشروط والأحكام'),
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate() || _residenceCountryId == null) return;

    final mobile = _mobile.replaceFirst(RegExp(r'^0+'), '');
    final form = FormData.fromMap({
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'mobile': mobile,
      'country_code': _phoneCountryCode,
      'residence_country_id': _residenceCountryId,
      'dob': _dob.text.trim(),
      'gender': _gender,
      'type': 'client',
      'password': _password.text,
      'password_confirmation': _password.text,
      'profile_image': await _defaultProfileImage(),
    });

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final registered = await auth.register(form);
    if (!mounted) return;
    if (!registered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? context.tr('register_failed', fallback: 'فشل التسجيل'))),
      );
      return;
    }

    final session = await auth.sendRegistrationSms();
    if (!mounted) return;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? context.tr('sms_send_failed', fallback: 'تعذر إرسال رمز التحقق'))),
      );
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => RegisterOtpScreen(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PasswordResetScaffold(
      step: 0,
      title: context.tr('personal_information', fallback: 'المعلومات الشخصية'),
      headerHero: const PasswordResetIllustration(size: 100),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RegisterFormField(
                label: context.tr('username', fallback: 'اسم مستخدم'),
                controller: _name,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
              ),
              const SizedBox(height: 12),
              RegisterFormField(
                label: context.tr('password', fallback: 'كلمة المرور'),
                controller: _password,
                iconAsset: FigmaAssets.loginPasswordGrey,
                obscure: _obscure,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return context.tr('password_min_length', fallback: '6 أحرف على الأقل');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              RegisterFormField(
                label: context.tr('email', fallback: 'البريد الالكتروني'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.tr('required', fallback: 'مطلوب');
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                    return context.tr('invalid_email', fallback: 'بريد غير صالح');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
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
                          borderSide: const BorderSide(color: AppColors.border),
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
              const SizedBox(height: 12),
              RegisterFormField(
                label: context.tr('date_of_birth', fallback: 'تاريخ الميلاد'),
                controller: _dob,
                readOnly: true,
                onTap: _pickDob,
                validator: (v) =>
                    v == null || v.isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
              ),
              const SizedBox(height: 12),
              RegisterDropdownField<String>(
                label: context.tr('gender', fallback: 'الجنس'),
                value: _gender,
                items: [
                  DropdownMenuItem(value: 'male', child: Text(context.tr('male', fallback: 'ذكر'))),
                  DropdownMenuItem(value: 'female', child: Text(context.tr('female', fallback: 'أنثى'))),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'male'),
                validator: (v) => v == null ? context.tr('required', fallback: 'مطلوب') : null,
              ),
              const SizedBox(height: 12),
              RegisterDropdownField<int>(
                label: context.tr('country_of_residence', fallback: 'بلد الإقامة'),
                value: _residenceCountryId,
                items: _countries
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['id'] as int,
                        child: Text(_countryLabel(c)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _residenceCountryId = v),
                validator: (v) => v == null ? context.tr('required', fallback: 'مطلوب') : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('accept_terms', fallback: 'أوافق على الشروط والأحكام'),
                      style: AppTypography.shamelBook(size: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PasswordResetPrimaryButton(
                label: context.tr('register', fallback: 'تسجيل'),
                loading: auth.loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
