import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom bar matching Figma tab labels (RTL order: الخريطة … المزيد).
class FigmaBottomNav extends StatelessWidget {
  const FigmaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.labels,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;

  static const tabCount = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 89,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(tabCount, (i) {
            final selected = i == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconFor(i, selected),
                      size: 24,
                      color: selected ? AppColors.primary : AppColors.iconMuted,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: AppTypography.shamelBook(
                        size: 10,
                        color: selected ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  IconData _iconFor(int index, bool selected) {
    const icons = [
      Icons.more_horiz_rounded,
      Icons.map_outlined,
      Icons.shopping_bag_outlined,
      Icons.restaurant_outlined,
      Icons.grid_view_rounded,
    ];
    const selectedIcons = [
      Icons.more_horiz,
      Icons.map_rounded,
      Icons.shopping_bag,
      Icons.restaurant,
      Icons.grid_view,
    ];
    return selected ? selectedIcons[index] : icons[index];
  }
}
