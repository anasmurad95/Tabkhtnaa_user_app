import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Figma 0:5032 — تسجيل دخول (RTL, mobile + password API)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _countryCode = TextEditingController(text: '+966');
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _countryCode.dispose();
    _mobile.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().login(
          countryCode: _countryCode.text.trim(),
          mobile: _mobile.text.trim(),
          password: _password.text,
        );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AuthProvider>().error ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: -166,
              right: -150,
              height: 320,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(FigmaAssets.loginHeaderWave, fit: BoxFit.fitWidth),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.asset(FigmaAssets.loginBgFood, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 43),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(FigmaAssets.loginBackWhite, width: 22, height: 22),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Image.asset(FigmaAssets.loginHeroHouse, width: 190, height: 190),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('login', fallback: 'تسجيل دخول'),
                        textAlign: TextAlign.center,
                        style: AppTypography.shamelBold(size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(height: 28),
                      _FigmaField(
                        label: context.tr('username', fallback: 'اسم مستخدم'),
                        controller: _mobile,
                        iconAsset: FigmaAssets.loginUserGrey,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 15),
                      _FigmaField(
                        label: context.tr('password', fallback: 'كلمة المرور'),
                        controller: _password,
                        iconAsset: FigmaAssets.loginPasswordGrey,
                        obscure: _obscure,
                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                        validator: (v) => v == null || v.length < 6 ? '6 أحرف على الأقل' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _submit,
                          child: auth.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(context.tr('login', fallback: 'تسجيل دخول')),
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
                            context.tr('forgot_password', fallback: 'نسيت كلمة المرور ؟'),
                            style: AppTypography.shamelBold(size: 10, color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _SocialButton(color: AppColors.facebookBlue, icon: FigmaAssets.facebookWhite, label: 'Facebook')),
                          const SizedBox(width: 8),
                          Expanded(child: _SocialButton(color: AppColors.accentRed, icon: FigmaAssets.googleWhite, label: 'Google')),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            context.tr('register_hint', fallback: 'يمكنك التسجيل  حساب الكتروني. '),
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
                      const SizedBox(height: 24),
                      const _LoginStepDots(active: 1),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.color, required this.icon, required this.label});

  final Color color;
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 21, height: 21),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.shamelBook(size: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginStepDots extends StatelessWidget {
  const _LoginStepDots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final on = i == active;
        return Container(
          width: on ? 29 : 10,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: on ? AppColors.indicatorInactive : AppColors.indicatorInactive.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
