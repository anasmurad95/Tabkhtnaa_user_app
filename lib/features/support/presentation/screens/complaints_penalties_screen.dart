import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/figma_underline_tabs.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/models/complaint_model.dart';
import '../../data/models/sanction_model.dart';
import '../providers/support_provider.dart';
import 'submit_complaint_screen.dart';

/// Figma — الشكاوي والعقوبات tabs.
class ComplaintsPenaltiesScreen extends StatefulWidget {
  const ComplaintsPenaltiesScreen({super.key});

  @override
  State<ComplaintsPenaltiesScreen> createState() => _ComplaintsPenaltiesScreenState();
}

class _ComplaintsPenaltiesScreenState extends State<ComplaintsPenaltiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().load();
    });
  }

  Future<void> _openSubmitComplaint() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()),
    );
    if (created == true && mounted) {
      context.read<SupportProvider>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupportProvider>();
    final tabIndex = provider.tab == SupportTab.complaints ? 0 : 1;

    return AppPageScaffold(
      title: context.tr('complaints_and_penalties', fallback: 'الشكاوي والعقوبات'),
      body: Column(
        children: [
          FigmaUnderlineTabs(
            tabs: [
              context.tr('complaints', fallback: 'الشكاوي'),
              context.tr('penalties', fallback: 'العقوبات'),
            ],
            currentIndex: tabIndex,
            onTap: (i) => provider.setTab(i == 0 ? SupportTab.complaints : SupportTab.penalties),
          ),
          Expanded(
            child: provider.loading
                ? const LoadingView()
                : provider.error != null
                    ? ErrorView(message: provider.error!, onRetry: provider.load)
                    : tabIndex == 0
                        ? _ComplaintsList(
                            items: provider.complaints,
                            onAdd: _openSubmitComplaint,
                          )
                        : _PenaltiesList(
                            items: provider.sanctions,
                            onSeen: (id) => _markSanctionSeen(context, provider, id),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _markSanctionSeen(
    BuildContext context,
    SupportProvider provider,
    int id,
  ) async {
    try {
      await provider.markSanctionSeen(id);
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, e.toString());
      }
    }
  }
}

class _ComplaintsList extends StatelessWidget {
  const _ComplaintsList({required this.items, required this.onAdd});

  final List<ComplaintModel> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('add_complaint', fallback: 'إضافة شكوى'),
                        style: AppTypography.shamelBold(size: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    context.tr('no_complaints', fallback: 'لا توجد شكاوى'),
                    style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final c = items[i];
                    final text = c.description?.isNotEmpty == true ? c.description! : (c.note ?? c.type ?? '');

                    return Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    text,
                                    style: AppTypography.shamelBook(size: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatRelativeTimeAr(c.createdAt),
                                    style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E9BD7).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${c.orderId ?? 0}',
                                style: AppTypography.shamelBold(size: 10, color: const Color(0xFF1E9BD7)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PenaltiesList extends StatelessWidget {
  const _PenaltiesList({required this.items, required this.onSeen});

  final List<SanctionModel> items;
  final Future<void> Function(int id) onSeen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          context.tr('no_penalties', fallback: 'لا توجد عقوبات'),
          style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = items[i];
        final text = s.note?.isNotEmpty == true ? s.note! : (s.type ?? '');

        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onSeen(s.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18, color: s.isNew ? AppColors.primary : AppColors.iconMuted),
                  if (s.isNew) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                  ],
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          text,
                          style: AppTypography.shamelBook(size: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatRelativeTimeAr(s.createdAt),
                          style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-2',
                      style: AppTypography.shamelBold(size: 10, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
