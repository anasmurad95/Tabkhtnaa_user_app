import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../settings/data/settings_repository.dart';

class ProfileContactScreen extends StatefulWidget {
  const ProfileContactScreen({super.key});

  @override
  State<ProfileContactScreen> createState() => _ProfileContactScreenState();
}

class _ProfileContactScreenState extends State<ProfileContactScreen> {
  Map<String, dynamic>? _company;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = SettingsRepository(context.read<ApiClient>());
      _company = await repo.companyInfo();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.tr('contact_us', fallback: 'اتصل بنا'),
      body: _loading
          ? const LoadingView()
          : _error != null
              ? AppEmptyState(
                  message: _error!,
                  icon: Icons.error_outline,
                  action: AppPrimaryButton(
                    label: context.tr('retry', fallback: 'إعادة المحاولة'),
                    onPressed: _load,
                  ),
                )
              : AppPageBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ContactRow(
                        icon: Icons.phone_outlined,
                        label: context.tr('phone', fallback: 'الهاتف'),
                        value: _company?['phone']?.toString() ?? '—',
                      ),
                      const SizedBox(height: 12),
                      _ContactRow(
                        icon: Icons.email_outlined,
                        label: context.tr('email', fallback: 'البريد'),
                        value: _company?['email']?.toString() ?? '—',
                      ),
                      const SizedBox(height: 12),
                      _ContactRow(
                        icon: Icons.chat_outlined,
                        label: 'WhatsApp',
                        value: _company?['whatsapp']?.toString() ?? '—',
                      ),
                      const SizedBox(height: 12),
                      _ContactRow(
                        icon: Icons.location_on_outlined,
                        label: context.tr('address', fallback: 'العنوان'),
                        value: _company?['address']?.toString() ?? '—',
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label, style: AppTypography.shamelBold(size: 12)),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
