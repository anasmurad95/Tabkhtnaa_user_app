import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/figma_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'figma_asset_image.dart';

/// Shared in-app page shell: orange curved header, white body, RTL back chevron.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBack = true,
    this.onBack,
    this.headerHeight = 120,
    this.actions,
    this.backgroundColor = AppColors.background,
  });

  final String title;
  final Widget body;
  final bool showBack;
  final VoidCallback? onBack;
  final double headerHeight;
  final List<Widget>? actions;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final canPop = Navigator.canPop(context);
    final displayBack = showBack && canPop;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: -80,
              left: -158,
              right: -158,
              height: 220,
              child: FigmaAssetImage(FigmaAssets.profileHeaderWave, fit: BoxFit.cover),
            ),
            Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: headerHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 56),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.shamelBold(size: 14, color: Colors.white),
                          ),
                        ),
                        if (displayBack)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: _AppBackButton(
                              onPressed: onBack ?? () => Navigator.maybePop(context),
                            ),
                          ),
                        if (actions != null && actions!.isNotEmpty)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: actions!,
                            ),
                          ),
                      ],
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

/// White chevron on orange header — placed at [AlignmentDirectional.centerStart]
/// (physical right in RTL, matching login / auth flow).
class _AppBackButton extends StatelessWidget {
  const _AppBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      icon: FigmaAssetImage(
        FigmaAssets.loginBackWhite,
        width: 22,
        height: 22,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
      ),
    );
  }
}

/// Standard horizontal padding for page body content.
class AppPageBody extends StatelessWidget {
  const AppPageBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.screenHorizontal,
      AppSpacing.screenVertical,
      AppSpacing.screenHorizontal,
      AppSpacing.xl,
    ),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Rounded card with soft elevation used across in-app lists.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  static BoxDecoration decoration({Color? color}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x1F000000),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: decoration(),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}

/// Section heading — w600, size 16.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.text, {super.key, this.padding});

  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: AppTypography.shamelBold(size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Centered empty state with icon and muted message.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.iconAsset,
    this.action,
  });

  final String message;
  final IconData? icon;
  final String? iconAsset;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null)
              FigmaAssetImage(iconAsset!, width: 48, height: 48)
            else
              Icon(icon ?? Icons.inbox_outlined, size: 48, color: AppColors.iconMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width primary pill button — height 48, radius 24.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: AppTypography.shamelBold(size: 14, color: Colors.white)),
      ),
    );
  }
}
