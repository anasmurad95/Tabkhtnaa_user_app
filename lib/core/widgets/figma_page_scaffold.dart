import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/figma_assets.dart';
import 'figma_asset_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_page_scaffold.dart';

export 'app_page_scaffold.dart';

/// Shared orange header + white body (Figma 360px auth/catalog pattern).
///
/// Legacy wrapper — prefer [AppPageScaffold] for new screens.
/// When [onBack] is omitted, back is hidden (tab roots). Pass [onBack] or
/// [showBack: true] on pushed routes.
class FigmaPageScaffold extends StatelessWidget {
  const FigmaPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.showBack,
    this.headerHeight = 120,
    this.actions,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final bool? showBack;
  final double headerHeight;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: title,
      body: body,
      showBack: showBack ?? onBack != null,
      onBack: onBack,
      headerHeight: headerHeight,
      actions: actions,
    );
  }
}

/// Login-style header with food overlay (register / forgot).
class FigmaAuthScaffold extends StatelessWidget {
  const FigmaAuthScaffold({
    super.key,
    required this.child,
    this.showBack = true,
    this.hero,
  });

  final Widget child;
  final bool showBack;
  final Widget? hero;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: -166,
              right: -150,
              height: 300,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  FigmaAssetImage(FigmaAssets.loginHeaderWave, fit: BoxFit.fitWidth),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.12,
                      child: FigmaAssetImage(FigmaAssets.loginBgFood, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  if (showBack)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: FigmaAssetImage(FigmaAssets.loginBackWhite, width: 22, height: 22),
                      ),
                    ),
                  if (hero != null) ...[hero!, const SizedBox(height: 8)],
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
