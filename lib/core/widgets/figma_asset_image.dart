import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/figma_assets.dart';

/// Loads Figma-exported assets whether they are SVG (misnamed `.png`) or raster.
class FigmaAssetImage extends StatelessWidget {
  const FigmaAssetImage(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.errorBuilder,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (FigmaAssets.isSvg(asset)) {
      return SvgPicture.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    }
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: color != null ? (colorBlendMode ?? BlendMode.srcIn) : null,
      errorBuilder: errorBuilder,
    );
  }
}
