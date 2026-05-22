import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/image_url.dart';
import '../../../addresses/presentation/screens/addresses_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../support/presentation/screens/complaints_screen.dart';

/// Figma 0:4440 — 4. menu - 1 (profile / الملف الشخصي)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned(
              top: -134,
              left: -158,
              right: -158,
              height: 292,
              child: Image.asset(FigmaAssets.profileHeaderWave, fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Image.asset(FigmaAssets.profileBackWhite, width: 9, height: 16),
                        const Spacer(),
                        Text(
                          context.tr('profile', fallback: 'الملف الشخصي'),
                          style: AppTypography.shamelBold(size: 14, color: Colors.white),
                        ),
                        const Spacer(),
                        const SizedBox(width: 9),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 3),
                      image: DecorationImage(
                        image: user?.profileImage != null
                            ? CachedNetworkImageProvider(resolveMediaUrl(user!.profileImage))
                            : const AssetImage(FigmaAssets.profileAvatarSample),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? context.tr('happy_customer', fallback: 'زبون سعيد'),
                    style: AppTypography.shamelBold(size: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      children: [
                        _ProfileCard(
                          children: [
                            _MenuRow(
                              title: context.tr('profile_settings', fallback: 'اعدادات البروفايل'),
                              active: true,
                              icon: FigmaAssets.profileSettingsOrange,
                            ),
                            _MenuRow(
                              title: context.tr('my_points', fallback: 'نقاطي'),
                              icon: FigmaAssets.profileStarOrange,
                            ),
                            _MenuRow(
                              title: context.tr('my_orders', fallback: 'طلباتي'),
                              icon: FigmaAssets.profileOrders,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OrdersScreen()),
                              ),
                            ),
                            _MenuRow(
                              title: context.tr('reports', fallback: 'تقارير'),
                              icon: FigmaAssets.profileOrders,
                            ),
                            _MenuRow(
                              title: context.tr('notifications', fallback: 'اشعارات'),
                              icon: FigmaAssets.profileNotification,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _ProfileCard(
                          children: [
                            _MenuRow(
                              title: context.tr('rating', fallback: 'التقييم'),
                              icon: FigmaAssets.profileStarOrange,
                            ),
                            _MenuRow(
                              title: context.tr('contact_us', fallback: 'اتصل بنا'),
                              icon: FigmaAssets.profileSettingsOrange,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChatScreen()),
                              ),
                            ),
                            _MenuRow(
                              title: 'Terms & Conditions',
                              icon: FigmaAssets.profileNotification,
                            ),
                            _MenuRow(
                              title: context.tr('addresses', fallback: 'العناوين'),
                              icon: FigmaAssets.profileOrders,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddressesScreen()),
                              ),
                            ),
                            _MenuRow(
                              title: context.tr('complaints', fallback: 'شكاوى'),
                              icon: FigmaAssets.profileOrders,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        InkWell(
                          onTap: () => auth.logout(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(FigmaAssets.profileLogout, width: 18, height: 18),
                              const SizedBox(width: 8),
                              Text(
                                context.tr('logout', fallback: 'تسجيل خروج'),
                                style: AppTypography.geBold(size: 14, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.title,
    required this.icon,
    this.active = false,
    this.onTap,
  });

  final String title;
  final String icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Image.asset(FigmaAssets.profileChevronOrange, width: 8, height: 8),
            const Spacer(),
            Text(
              title,
              style: AppTypography.shamelBold(
                size: 12,
                color: active ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(icon, width: 22, height: 22),
          ],
        ),
      ),
    );
  }
}
