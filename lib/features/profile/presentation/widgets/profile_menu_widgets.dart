import 'package:flutter/material.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/figma_asset_image.dart';

/// Profile hub menu row — icon at start (right in RTL), chevron at end (left).
class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.title,
    this.icon,
    this.iconData,
    this.active = false,
    this.greyIcon = false,
    this.onTap,
    this.showDivider = true,
  }) : assert(icon != null || iconData != null);

  final String title;
  final String? icon;
  final IconData? iconData;
  final bool active;
  final bool greyIcon;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final iconColor = greyIcon ? AppColors.iconMuted : AppColors.primary;
    final horizontalPadding = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 20.0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.border, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: icon != null
                  ? FigmaAssetImage(
                      icon!,
                      width: 22,
                      height: 22,
                      color: greyIcon ? AppColors.iconMuted : null,
                      colorBlendMode: greyIcon ? BlendMode.srcIn : null,
                    )
                  : Icon(iconData, size: 22, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: AppTypography.shamelBold(
                  size: 12,
                  color: active ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_left, size: 18, color: AppColors.iconMuted),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppCard.decoration(),
      child: Column(children: children),
    );
  }
}

class ProfileSettingsRow extends StatelessWidget {
  const ProfileSettingsRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: AppColors.border, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            FigmaAssetImage(FigmaAssets.profileChevronOrange, width: 8, height: 8),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: AppTypography.shamelBold(size: 12, color: AppColors.textPrimary),
                  ),
                  if (label.isNotEmpty)
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
