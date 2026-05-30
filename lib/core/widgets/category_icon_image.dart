import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/category_assets.dart';
import '../theme/app_colors.dart';
import '../utils/image_url.dart';

/// Category tile icon: API URL → bundled asset → backend path by key → placeholder.
class CategoryIconImage extends StatelessWidget {
  const CategoryIconImage({
    super.key,
    this.categoryKey,
    this.iconUrl,
    this.size = 48,
  });

  final String? categoryKey;
  final String? iconUrl;
  final double size;

  String get _safeKey => categoryKey?.trim() ?? '';

  String? _resolvedUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final resolved = resolveMediaUrl(raw);
    return resolved.isEmpty ? null : resolved;
  }

  @override
  Widget build(BuildContext context) {
    final apiUrl = _resolvedUrl(iconUrl);
    if (apiUrl != null) {
      return _NetworkCategoryIcon(
        url: apiUrl,
        size: size,
        onError: () => _buildLocalAsset(fallback: _buildBackendOrPlaceholder),
      );
    }

    return _buildLocalAsset(fallback: _buildBackendOrPlaceholder);
  }

  Widget _buildLocalAsset({required Widget Function() fallback}) {
    final asset = CategoryAssets.assetForKey(_safeKey);
    if (asset == null) return fallback();

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallback(),
      ),
    );
  }

  Widget _buildBackendOrPlaceholder() {
    final backendUrl = _resolvedUrl(CategoryAssets.backendMediaPathForKey(_safeKey));
    if (backendUrl != null) {
      return _NetworkCategoryIcon(
        url: backendUrl,
        size: size,
        onError: () => _DefaultCategoryIcon(size: size),
      );
    }
    return _DefaultCategoryIcon(size: size);
  }
}

class _NetworkCategoryIcon extends StatelessWidget {
  const _NetworkCategoryIcon({
    required this.url,
    required this.size,
    required this.onError,
  });

  final String url;
  final double size;
  final Widget Function() onError;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => onError(),
      ),
    );
  }
}

class _DefaultCategoryIcon extends StatelessWidget {
  const _DefaultCategoryIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ColoredBox(
        color: AppColors.primaryLight,
        child: Center(
          child: Icon(Icons.restaurant, color: AppColors.primary, size: size * 0.55),
        ),
      ),
    );
  }
}
