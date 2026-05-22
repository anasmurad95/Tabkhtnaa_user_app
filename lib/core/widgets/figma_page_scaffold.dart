import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/figma_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Shared orange header + white body (Figma 360px auth/catalog pattern).
class FigmaPageScaffold extends StatelessWidget {
  const FigmaPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.headerHeight = 120,
    this.actions,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final double headerHeight;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned(
              top: -80,
              left: -158,
              right: -158,
              height: 220,
              child: Image.asset(FigmaAssets.profileHeaderWave, fit: BoxFit.cover),
            ),
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: headerHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          if (onBack != null)
                            InkWell(
                              onTap: onBack,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(FigmaAssets.profileBackWhite, width: 9, height: 16),
                              ),
                            )
                          else
                            const SizedBox(width: 25),
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: AppTypography.shamelBold(size: 14, color: Colors.white),
                            ),
                          ),
                          if (actions != null) ...actions! else const SizedBox(width: 25),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ],
        ),
      ),
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
                  Image.asset(FigmaAssets.loginHeaderWave, fit: BoxFit.fitWidth),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.asset(FigmaAssets.loginBgFood, fit: BoxFit.cover),
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
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: Image.asset(FigmaAssets.loginBackWhite, width: 22, height: 22),
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
