import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../localization/data/models/app_language.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../localization/presentation/providers/translation_provider.dart';
import '../../../localization/presentation/widgets/language_picker_sheet.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_header_clipper.dart';
import '../widgets/splash_wave_clipper.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Figma 0:5032 — تسجيل دخول (RTL, mobile + password API)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _illustrationSize = 190.0;

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _password = TextEditingController();
  String _phoneCountryCode = '962';
  String _mobile = '';
  bool _obscure = true;
  AppLanguage? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TranslationProvider>().loadLanguages();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _openLanguagePicker() async {
    final l10n = context.read<TranslationProvider>();
    unawaited(l10n.loadLanguages());

    final picked = await showLanguagePickerSheet(
      context,
      languages: l10n.languages,
      selected: _selectedLanguage,
      error: l10n.error,
    );

    if (picked != null && mounted) {
      setState(() => _selectedLanguage = picked);
      await l10n.selectLanguage(picked.code);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().login(
          countryCode: _phoneCountryCode,
          mobile: _mobile,
          password: _password.text,
        );
    if (!ok && mounted) {
      AppToast.error(
        context,
        context.read<AuthProvider>().error ??
            context.tr('login_failed', fallback: 'فشل تسجيل الدخول'),
      );
      return;
    }
    if (ok && mounted) {
      AppToast.success(
        context,
        context.tr('login_success', fallback: 'تم تسجيل الدخول بنجاح'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final headerH = constraints.maxHeight * 0.33;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: headerH,
                        width: double.infinity,
                        child: ClipPath(
                          clipper: OnboardingHeaderClipper(),
                          child: const SplashFoodHeaderBackground(),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            43,
                            _illustrationSize * 0.38,
                            43,
                            24,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  context.tr('login', fallback: 'تسجيل دخول'),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.shamelBold(size: 20, color: AppColors.primary),
                                ),
                                const SizedBox(height: 28),
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
                                const SizedBox(height: 15),
                                _FigmaField(
                                  label: context.tr('password', fallback: 'كلمة المرور'),
                                  controller: _password,
                                  iconAsset: FigmaAssets.loginPasswordGrey,
                                  obscure: _obscure,
                                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                                  validator: (v) => v == null || v.length < 6
                                      ? context.tr('password_min_length', fallback: '6 أحرف على الأقل')
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: auth.loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppRadii.pillButton),
                                      ),
                                    ),
                                    child: auth.loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            context.tr('login', fallback: 'تسجيل دخول'),
                                            style: AppTypography.shamelBold(size: 14, color: Colors.white),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                    ),
                                    child: Text(
                                      context.tr('forgot_password', fallback: 'نسيت كلمة المرور؟'),
                                      style: AppTypography.shamelBold(size: 10, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      context.tr(
                                        'register_hint',
                                        fallback: 'يمكنك التسجيل  حساب الكتروني. ',
                                      ),
                                      style: AppTypography.shamelBold(size: 10, color: AppColors.textPrimary),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                      ),
                                      child: Text(
                                        context.tr('click_here', fallback: 'اضغط هنا'),
                                        style: AppTypography.shamelBold(size: 10, color: AppColors.accent),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: headerH - _illustrationSize * 0.45,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _HouseLogoWithDashedCircle(size: _illustrationSize),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openLanguagePicker,
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: FigmaAssetImage(
                                FigmaAssets.globeWhite,
                                width: 24,
                                height: 24,
                                color: Colors.white,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.language, size: 24, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HouseLogoWithDashedCircle extends StatelessWidget {
  const _HouseLogoWithDashedCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DashedCirclePainter(
              color: AppColors.success,
              strokeWidth: 2,
              dashLength: 7,
              gapLength: 5,
            ),
          ),
          FigmaAssetImage(
            FigmaAssets.loginHeroHouse,
            width: size * 0.88,
            height: size * 0.88,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + gapLength)) / radius;
      final sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}

class _FigmaField extends StatelessWidget {
  const _FigmaField({
    required this.label,
    required this.controller,
    required this.iconAsset,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String iconAsset;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTypography.shamelBook(size: 10, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.shamelBook(size: 12),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(iconAsset, width: 20, height: 20),
            ),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.iconMuted,
                      size: 18,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
