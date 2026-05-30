import 'package:flutter/material.dart';

import '../constants/figma_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'figma_asset_image.dart';

/// Bottom bar — RTL order: المزيد · المشتريات · التصنيفات · الطهاة · الخريطة
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
                    _NavIcon(index: i, selected: selected),
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
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.index, required this.selected});

  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (index == 0) {
      return FigmaAssetImage(
        FigmaAssets.navMore,
        width: 24,
        height: 24,
        color: selected ? AppColors.primary : AppColors.iconMuted,
      );
    }

    const icons = [
      Icons.shopping_bag_outlined,
      Icons.grid_view_rounded,
      Icons.restaurant_outlined,
      Icons.map_outlined,
    ];
    const selectedIcons = [
      Icons.shopping_bag,
      Icons.grid_view,
      Icons.restaurant,
      Icons.map_rounded,
    ];
    final iconIndex = index - 1;
    return Icon(
      selected ? selectedIcons[iconIndex] : icons[iconIndex],
      size: 24,
      color: selected ? AppColors.primary : AppColors.iconMuted,
    );
  }
}
