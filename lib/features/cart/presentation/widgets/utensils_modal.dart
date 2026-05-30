import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Figma utensils modal — كاسات / صحون / ملاعق / شراشف checkboxes.
Future<Map<String, bool>?> showUtensilsModal(BuildContext context) {
  return showDialog<Map<String, bool>>(
    context: context,
    builder: (ctx) {
      final options = <String, bool>{
        'cups': false,
        'plates': false,
        'spoons': false,
        'napkins': false,
      };

      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ctx.tr('order_details', fallback: 'تفاصيل الطلب'),
                      textAlign: TextAlign.center,
                      style: AppTypography.shamelBold(size: 14),
                    ),
                    const SizedBox(height: 16),
                    _CheckRow(
                      label: ctx.tr('cups', fallback: 'كاسات'),
                      value: options['cups']!,
                      onChanged: (v) => setModalState(() => options['cups'] = v ?? false),
                    ),
                    _CheckRow(
                      label: ctx.tr('plates', fallback: 'صحون'),
                      value: options['plates']!,
                      onChanged: (v) => setModalState(() => options['plates'] = v ?? false),
                    ),
                    _CheckRow(
                      label: ctx.tr('spoons', fallback: 'ملاعق'),
                      value: options['spoons']!,
                      onChanged: (v) => setModalState(() => options['spoons'] = v ?? false),
                    ),
                    _CheckRow(
                      label: ctx.tr('napkins', fallback: 'شراشف'),
                      value: options['napkins']!,
                      onChanged: (v) => setModalState(() => options['napkins'] = v ?? false),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, options),
                        child: Text(ctx.tr('confirm', fallback: 'تأكيد')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTypography.shamelBook(size: 12)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
