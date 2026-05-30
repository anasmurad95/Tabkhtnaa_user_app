import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/profile_avatar_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/models/chef_model.dart';
import '../providers/home_provider.dart';
import 'chef_detail_screen.dart';

/// Figma — الطهاة tab with location groups and search.
class ChefsScreen extends StatefulWidget {
  const ChefsScreen({super.key});

  @override
  State<ChefsScreen> createState() => _ChefsScreenState();
}

class _ChefsScreenState extends State<ChefsScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadChefs();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final auth = context.watch<AuthProvider>();
    final groups = home.chefsByLocation;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _ChefsHeader(
              onProfile: () {},
              profileImage: auth.user?.profileImage,
              profileName: auth.user?.name,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 12, 30, 8),
              child: TextField(
                controller: _search,
                style: AppTypography.shamelBook(size: 12),
                decoration: InputDecoration(
                  hintText: context.tr('search_chef', fallback: 'ابحث عن طاهي'),
                  prefixIcon: const Icon(Icons.search, color: AppColors.iconMuted, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.primary),
                    onPressed: () => home.loadChefs(search: _search.text.trim()),
                  ),
                ),
                onSubmitted: (_) => home.loadChefs(search: _search.text.trim()),
              ),
            ),
            Expanded(
              child: home.loading
                  ? const LoadingView()
                  : home.error != null
                      ? ErrorView(message: home.error!, onRetry: () => home.loadChefs())
                      : groups.isEmpty
                          ? Center(
                              child: Text(
                                context.tr('no_chefs', fallback: 'لا يوجد طهاة'),
                                style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: () => home.loadChefs(search: _search.text.trim()),
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(30, 8, 30, 100),
                                children: [
                                  for (final entry in groups.entries) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                                      child: Text(
                                        entry.key,
                                        style: AppTypography.shamelBold(size: 12, color: AppColors.primary),
                                      ),
                                    ),
                                    ...entry.value.map((chef) => Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: _ChefCard(
                                            chef: chef,
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ChefDetailScreen(chefId: chef.id),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChefsHeader extends StatelessWidget {
  const _ChefsHeader({
    required this.onProfile,
    this.profileImage,
    this.profileName,
  });

  final VoidCallback onProfile;
  final String? profileImage;
  final String? profileName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FigmaAssetImage(FigmaAssets.profileHeaderWave, fit: BoxFit.cover),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: onProfile,
                    child: ProfileAvatarImage(imageUrl: profileImage, size: 32, initials: profileName?.substring(0, 1)),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('nav_chefs', fallback: 'الطهاة'),
                      textAlign: TextAlign.center,
                      style: AppTypography.shamelBold(size: 14, color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.tune, color: Colors.white, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChefCard extends StatelessWidget {
  const _ChefCard({required this.chef, required this.onTap});

  final ChefModel chef;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rating = chef.averageRating?.toStringAsFixed(1) ?? '4.5';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              ProfileAvatarImage(imageUrl: chef.profileImage, size: 48, initials: chef.name.substring(0, 1)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(chef.name, style: AppTypography.shamelBold(size: 12)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (chef.distance != null)
                          Text(
                            '${chef.distance!.toStringAsFixed(1)} km',
                            style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                          ),
                        const SizedBox(width: 4),
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Icon(Icons.restaurant, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text(rating, style: AppTypography.shamelBold(size: 10, color: AppColors.primary)),
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
