import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/localization/presentation/providers/translation_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'nav_home'),
    (Icons.restaurant_menu_rounded, Icons.restaurant_menu_outlined, 'nav_menu'),
    (Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'nav_cart'),
    (Icons.person_rounded, Icons.person_outline, 'nav_profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<TranslationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              final item = _items[i];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? item.$1 : item.$2,
                          color: selected ? AppColors.primary : AppColors.textMuted,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.tr(item.$3),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: selected ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
