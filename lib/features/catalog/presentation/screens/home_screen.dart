import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/image_url.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/figma_meal_row.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../providers/home_provider.dart';
import 'meal_detail_screen.dart';

/// Figma 0:2886, 0:2651 — categories / home tab
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHome();
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => home.loadHome(search: _search.text.trim()),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _CategoryHeader(onNotifications: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              })),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 12, 30, 8),
                  child: TextField(
                    controller: _search,
                    style: AppTypography.shamelBook(size: 12),
                    decoration: InputDecoration(
                      hintText: context.tr('search_meals', fallback: 'ابحث عن وجبة أو طاهٍ'),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: FigmaAssetImage(FigmaAssets.loginUserGrey, width: 18, height: 18),
                      ),
                    ),
                    onSubmitted: (_) => home.loadHome(search: _search.text.trim()),
                  ),
                ),
              ),
              if (home.loading) const SliverFillRemaining(child: LoadingView()),
              if (!home.loading && home.error != null)
                SliverFillRemaining(child: ErrorView(message: home.error!, onRetry: home.loadHome)),
              if (!home.loading && home.error == null) ...[
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      children: [
                        _CategoryChip(
                          label: context.tr('all', fallback: 'الكل'),
                          selected: home.selectedCategoryId == null,
                          onTap: () => home.selectCategory(null),
                        ),
                        ...home.categories.map(
                          (c) => _CategoryChip(
                            label: c.name,
                            selected: home.selectedCategoryId == c.id,
                            onTap: () => home.selectCategory(c.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (home.chefs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 16, 30, 8),
                      child: Text(
                        context.tr('nearby_chefs', fallback: 'طهاة قريبون'),
                        style: AppTypography.shamelBold(size: 14, color: AppColors.primary),
                      ),
                    ),
                  ),
                if (home.chefs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        itemCount: home.chefs.take(10).length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final chef = home.chefs[i];
                          return _ChefChip(name: chef.name, image: chef.profileImage);
                        },
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(30, 12, 30, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final meal = home.meals[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FigmaMealRow(
                            name: meal.name,
                            price: '${meal.price.toStringAsFixed(2)} ${context.tr('currency', fallback: 'د.أ')}',
                            imageUrl: meal.image,
                            subtitle: meal.description,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)),
                            ),
                          ),
                        );
                      },
                      childCount: home.meals.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 112,
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
                        onTap: onNotifications,
                        child: FigmaAssetImage(FigmaAssets.profileNotification, width: 22, height: 22),
                      ),
                      Expanded(
                        child: Text(
                          context.tr('nav_categories', fallback: 'التصنيفات'),
                          textAlign: TextAlign.center,
                          style: AppTypography.shamelBold(size: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pillButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.pillButton),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: AppTypography.shamelBold(
                size: 12,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChefChip extends StatelessWidget {
  const _ChefChip({required this.name, this.image});

  final String name;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: image != null && image!.isNotEmpty
              ? CachedNetworkImageProvider(resolveMediaUrl(image))
              : null,
          child: image == null || image!.isEmpty
              ? FigmaAssetImage(FigmaAssets.profileAvatarSample, width: 40, height: 40)
              : null,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.shamelBook(size: 10), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
