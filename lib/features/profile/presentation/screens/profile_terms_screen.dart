import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Terms & Conditions from GET /auth/term-and-condition
class ProfileTermsScreen extends StatefulWidget {
  const ProfileTermsScreen({super.key});

  @override
  State<ProfileTermsScreen> createState() => _ProfileTermsScreenState();
}

class _ProfileTermsScreenState extends State<ProfileTermsScreen> {
  bool _loading = true;
  String _text = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final terms = await auth.loadTermsAndConditions();
      if (!mounted) return;
      if (terms == null && auth.error != null) {
        AppToast.error(context, auth.error!);
      } else if (terms == null) {
        AppToast.info(
          context,
          context.tr('terms_unavailable', fallback: 'الشروط غير متوفرة حالياً'),
        );
      }
      setState(() {
        _text = terms ?? context.tr('terms_unavailable', fallback: 'الشروط غير متوفرة حالياً');
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.tr('terms_and_conditions', fallback: 'Terms & Conditions'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Text(
                  _text,
                  style: AppTypography.shamelBook(size: 12, color: AppColors.textPrimary),
                ),
              ),
            ),
    );
  }
}
