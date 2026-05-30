import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Two-tab bar with orange underline (Figma notifications / complaints).
class FigmaUnderlineTabs extends StatelessWidget {
  const FigmaUnderlineTabs({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final selected = i == currentIndex;
        return Expanded(
          child: InkWell(
            onTap: () => onTap(i),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: AppTypography.shamelBold(
                      size: 12,
                      color: selected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
