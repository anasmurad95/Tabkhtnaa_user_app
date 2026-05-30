import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/figma_assets.dart';
import '../theme/app_colors.dart';
import '../utils/image_url.dart';

/// Network profile avatar that handles SVG payloads served with raster extensions.
class ProfileAvatarImage extends StatefulWidget {
  const ProfileAvatarImage({
    super.key,
    this.imageUrl,
    this.size = 100,
    this.initials,
    this.borderColor = AppColors.border,
    this.borderWidth = 2,
  });

  final String? imageUrl;
  final double size;
  final String? initials;
  final Color borderColor;
  final double borderWidth;

  @override
  State<ProfileAvatarImage> createState() => _ProfileAvatarImageState();
}

enum _AvatarLoadMode { probing, raster, svg, fallback }

class _ProfileAvatarImageState extends State<ProfileAvatarImage> {
  _AvatarLoadMode _mode = _AvatarLoadMode.probing;

  @override
  void initState() {
    super.initState();
    _resolveLoadMode();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolveLoadMode();
    }
  }

  Future<void> _resolveLoadMode() async {
    final url = _resolvedUrl;
    if (url.isEmpty) {
      if (mounted) setState(() => _mode = _AvatarLoadMode.fallback);
      return;
    }

    if (_isSvgUrl(url)) {
      if (mounted) setState(() => _mode = _AvatarLoadMode.svg);
      return;
    }

    if (mounted) setState(() => _mode = _AvatarLoadMode.probing);

    final isSvg = await _probeSvgContentType(url);
    if (!mounted) return;

    setState(() => _mode = isSvg ? _AvatarLoadMode.svg : _AvatarLoadMode.raster);
  }

  String get _resolvedUrl {
    final raw = widget.imageUrl?.trim();
    if (raw == null || raw.isEmpty) return '';
    return resolveMediaUrl(raw);
  }

  static bool _isSvgUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.svg');
  }

  static Future<bool> _probeSvgContentType(String url) async {
    try {
      final response = await Dio().head<dynamic>(
        url,
        options: Options(followRedirects: true, validateStatus: (status) => status != null && status < 500),
      );
      final contentType = response.headers.value('content-type')?.toLowerCase() ?? '';
      return contentType.contains('svg');
    } catch (_) {
      return false;
    }
  }

  void _scheduleMode(_AvatarLoadMode mode) {
    if (_mode == mode || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _mode != mode) setState(() => _mode = mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: widget.borderColor, width: widget.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    switch (_mode) {
      case _AvatarLoadMode.probing:
        return _placeholderContent(showProgress: true);
      case _AvatarLoadMode.svg:
        return _buildSvg();
      case _AvatarLoadMode.raster:
        return _buildRaster();
      case _AvatarLoadMode.fallback:
        return _placeholderContent();
    }
  }

  Widget _buildRaster() {
    return Image.network(
      _resolvedUrl,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        _scheduleMode(_AvatarLoadMode.svg);
        return _placeholderContent(showProgress: true);
      },
    );
  }

  Widget _buildSvg() {
    return SvgPicture.network(
      _resolvedUrl,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      placeholderBuilder: (_) => _placeholderContent(showProgress: true),
      errorBuilder: (context, error, stackTrace) {
        _scheduleMode(_AvatarLoadMode.fallback);
        return _placeholderContent();
      },
    );
  }

  Widget _placeholderContent({bool showProgress = false}) {
    final initials = widget.initials?.trim();
    if (initials != null && initials.isNotEmpty) {
      return CircleAvatar(
        radius: widget.size / 2,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          initials.substring(0, 1).toUpperCase(),
          style: TextStyle(
            fontSize: widget.size * 0.36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (showProgress) {
      return const ColoredBox(
        color: AppColors.primaryLight,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    return Image.asset(
      FigmaAssets.profileAvatarSample,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
    );
  }
}
