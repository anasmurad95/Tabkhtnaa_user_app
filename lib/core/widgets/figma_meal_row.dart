import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/figma_assets.dart';
import 'figma_asset_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../utils/image_url.dart';

/// Meal list row — Figma 9.x / 8.x cart item (~319×96).
class FigmaMealRow extends StatelessWidget {
  const FigmaMealRow({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onDelete,
  });

  final String name;
  final String price;
  final String? imageUrl;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          height: 96,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.accentRed, size: 20),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name, style: AppTypography.shamelBold(size: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted)),
                    ],
                    const SizedBox(height: 4),
                    Text(price, style: AppTypography.shamelBold(size: 12, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 43,
                  height: 43,
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? CachedNetworkImage(imageUrl: resolveMediaUrl(imageUrl), fit: BoxFit.cover)
                      : ColoredBox(
                          color: AppColors.primaryLight,
                          child: FigmaAssetImage(FigmaAssets.loginHeroHouse, fit: BoxFit.cover),
                        ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
