import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Accessories picker — maps API accessories by [key] (cups, plates, spoons, napkins).
Future<List<int>?> showUtensilsModal(
  BuildContext context, {
  required List<Map<String, dynamic>> accessories,
}) {
  final selected = <int>{};

  return showDialog<List<int>>(
    context: context,
    builder: (ctx) {
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
                    for (final accessory in accessories)
                      _CheckRow(
                        label: accessory['name']?.toString() ??
                            accessory['default_name']?.toString() ??
                            accessory['key']?.toString() ??
                            '',
                        value: selected.contains(accessory['id'] as int),
                        onChanged: (v) {
                          setModalState(() {
                            final id = accessory['id'] as int;
                            if (v == true) {
                              selected.add(id);
                            } else {
                              selected.remove(id);
                            }
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, selected.toList()),
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
