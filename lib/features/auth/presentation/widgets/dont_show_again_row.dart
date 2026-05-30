import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class DontShowAgainRow extends StatelessWidget {
  const DontShowAgainRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1),
                color: value ? AppColors.primary : Colors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
