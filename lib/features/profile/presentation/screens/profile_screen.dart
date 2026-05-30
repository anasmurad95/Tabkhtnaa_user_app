import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/profile_avatar_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../support/presentation/screens/complaints_penalties_screen.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_menu_widgets.dart';
import '../widgets/profile_sidebar_clipper.dart';
import 'profile_settings_screen.dart';
import 'profile_terms_screen.dart';

/// Figma — الملف الشخصي (profile hub): orange left sidebar + white content.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _profileDividerBlue = Color(0xFF1E9BD7);

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('coming_soon', fallback: 'قريباً'))),
    );
  }

  bool _isOnline(String? status) =>
      status == null || status == 'online' || status == 'available';

  double _sidebarWidth(double screenWidth) =>
      (screenWidth * 0.22).clamp(72.0, 120.0);

  String? _initials(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final user = auth.user;
    final online = _isOnline(user?.onlineStatus);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sidebarWidth = _sidebarWidth(screenWidth);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: sidebarWidth,
                  child: ClipPath(
                    clipper: ProfileSidebarClipper(),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.splashGradient),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Text(
                            context.tr('profile', fallback: 'الملف الشخصي'),
                            textAlign: TextAlign.center,
                            style: AppTypography.shamelBold(
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProfileAvatarImage(
                        imageUrl: user?.profileImage,
                        initials: _initials(user?.name),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          user?.name ?? context.tr('happy_customer', fallback: 'زبون سعيد'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.shamelBold(size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Switch.adaptive(
                        value: online,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        thumbColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppColors.primary
                              : null,
                        ),
                        onChanged: profile.loading ? null : (v) => profile.setOnline(v),
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: _profileDividerBlue,
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            ProfileMenuRow(
                              title: context.tr('profile_settings', fallback: 'اعدادات البروفايل'),
                              active: true,
                              icon: FigmaAssets.profileSettingsOrange,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
                              ),
                            ),
                            ProfileMenuRow(
                              title: context.tr('my_points', fallback: 'نقاطي'),
                              icon: FigmaAssets.profileStarOrange,
                              onTap: () => _comingSoon(context),
                            ),
                            ProfileMenuRow(
                              title: context.tr('my_orders', fallback: 'طلباتي'),
                              iconData: Icons.inventory_2_outlined,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OrdersScreen()),
                              ),
                            ),
                            ProfileMenuRow(
                              title: context.tr(
                                'complaints_and_penalties',
                                fallback: 'شكاوي وعقوبات',
                              ),
                              iconData: Icons.description_outlined,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ComplaintsPenaltiesScreen()),
                              ),
                            ),
                            ProfileMenuRow(
                              title: context.tr('notifications', fallback: 'اشعارات'),
                              icon: FigmaAssets.profileNotification,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                              ),
                            ),
                            ProfileMenuRow(
                              title: context.tr('rating', fallback: 'التقييم'),
                              icon: FigmaAssets.profileStarOrange,
                              onTap: () => _comingSoon(context),
                            ),
                            ProfileMenuRow(
                              title: context.tr('contact_us', fallback: 'اتصل بنا'),
                              iconData: Icons.headset_mic_outlined,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChatListScreen()),
                              ),
                            ),
                            ProfileMenuRow(
                              title: context.tr(
                                'terms_and_conditions',
                                fallback: 'Terms & Conditions',
                              ),
                              greyIcon: true,
                              iconData: Icons.chat_bubble_outline,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileTermsScreen()),
                              ),
                            ),
                            ProfileMenuRow(
                              title: context.tr('logout', fallback: 'تسجيل خروج'),
                              greyIcon: true,
                              icon: FigmaAssets.profileLogout,
                              showDivider: false,
                              onTap: profile.loading ? null : () => auth.logout(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
