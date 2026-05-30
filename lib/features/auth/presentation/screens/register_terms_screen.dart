import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_reset_scaffold.dart';
import 'register_success_screen.dart';

/// Flow B step 3 — الشروط والأحكام
class RegisterTermsScreen extends StatefulWidget {
  const RegisterTermsScreen({super.key});

  @override
  State<RegisterTermsScreen> createState() => _RegisterTermsScreenState();
}

class _RegisterTermsScreenState extends State<RegisterTermsScreen> {
  bool _accepted = false;
  bool _loadingTerms = true;
  String _termsText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTerms());
  }

  Future<void> _loadTerms() async {
    final terms = await context.read<AuthProvider>().loadTermsAndConditions();
    if (!mounted) return;
    setState(() {
      _termsText = terms ?? context.tr('terms_unavailable', fallback: 'الشروط غير متوفرة حالياً');
      _loadingTerms = false;
    });
    if (terms == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthProvider>().error ??
                context.tr('terms_load_failed', fallback: 'تعذر تحميل الشروط'),
          ),
        ),
      );
    }
  }

  void _finish() {
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('accept_terms_required', fallback: 'يجب الموافقة على الشروط والأحكام'),
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PasswordResetScaffold(
      step: 2,
      title: context.tr('terms_and_conditions', fallback: 'الشروط والأحكام'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _loadingTerms
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _termsText,
                        style: AppTypography.shamelBook(size: 11, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _accepted,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _accepted = v ?? false),
              ),
              Expanded(
                child: Text(
                  context.tr('accept_terms', fallback: 'أوافق على الشروط والأحكام'),
                  style: AppTypography.shamelBook(size: 10),
                ),
              ),
            ],
          ),
          PasswordResetPrimaryButton(
            label: context.tr('finish_registration', fallback: 'إنهاء التسجيل'),
            loading: auth.loading,
            onPressed: _finish,
          ),
        ],
      ),
    );
  }
}
