import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../utils/image_url.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.name,
    required this.price,
    this.image,
    this.rating,
    this.onTap,
    this.onAdd,
  });

  final String name;
  final double price;
  final String? image;
  final double? rating;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
                      child: image != null && image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: resolveMediaUrl(image),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.primaryLight,
                              child: const Center(child: Icon(Icons.restaurant, size: 40, color: AppColors.primary)),
                            ),
                    ),
                    if (rating != null)
                      Positioned(
                        top: AppSpacing.xs,
                        right: AppSpacing.xs,
                        child: _Badge(label: rating!.toStringAsFixed(1), icon: Icons.star_rounded),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    if (onAdd != null)
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.warning),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
