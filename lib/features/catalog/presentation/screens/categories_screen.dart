import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../../../../core/constants/category_assets.dart';
import '../../../../core/constants/figma_assets.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_radii.dart';

import '../../../../core/theme/app_typography.dart';

import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/category_icon_image.dart';

import '../../../../core/widgets/error_view.dart';

import '../../../../core/widgets/figma_asset_image.dart';

import '../../../../core/widgets/loading_view.dart';

import '../../../../core/widgets/profile_avatar_image.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../localization/presentation/extensions/translation_context.dart';

import '../../data/models/category_model.dart';

import '../providers/home_provider.dart';

import 'meals_list_screen.dart';



/// Figma — التصنيفات 3-column grid tab.

class CategoriesScreen extends StatefulWidget {

  const CategoriesScreen({super.key});



  @override

  State<CategoriesScreen> createState() => _CategoriesScreenState();

}



class _CategoriesScreenState extends State<CategoriesScreen> {

  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<HomeProvider>().loadCategories();

    });

  }



  @override

  Widget build(BuildContext context) {

    final home = context.watch<HomeProvider>();

    final auth = context.watch<AuthProvider>();



    return AppPageScaffold(
      title: context.tr('nav_categories', fallback: 'التصنيفات'),
      showBack: false,
      leading: ProfileAvatarImage(
        imageUrl: auth.user?.profileImage,
        size: 32,
        initials: auth.user?.name?.isNotEmpty == true ? auth.user!.name.substring(0, 1) : null,
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune, color: Colors.white, size: 22),
        ),
      ],
      body: home.loading
          ? const LoadingView()
          : home.error != null
              ? ErrorView(message: home.error!, onRetry: home.loadCategories)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: home.loadCategories,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: home.categories.length,
                    itemBuilder: (_, i) => _CategoryTile(
                      category: home.categories[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealsListScreen(category: home.categories[i]),
                        ),
                      ),
                    ),
                  ),
                ),
    );

  }

}



class _CategoryTile extends StatelessWidget {

  const _CategoryTile({required this.category, required this.onTap});



  final CategoryModel category;

  final VoidCallback onTap;



  @override

  Widget build(BuildContext context) {

    final label = category.key.isNotEmpty
        ? context.tr(
            category.key,
            fallback: CategoryAssets.labelFallbackForKey(category.key) ??
                category.displayName,
          )
        : category.displayName;



    return Material(

      color: AppColors.surface,

      borderRadius: BorderRadius.circular(AppRadii.md),

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(AppRadii.md),

        child: Container(

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(AppRadii.md),

            border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),

          ),

          padding: const EdgeInsets.all(10),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              ClipRRect(

                borderRadius: BorderRadius.circular(8),

                child: CategoryIconImage(

                  categoryKey: category.key,

                  iconUrl: category.image,

                  size: 48,

                ),

              ),

              const SizedBox(height: 8),

              Text(

                label,

                textAlign: TextAlign.center,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: AppTypography.shamelBold(size: 10),

              ),

            ],

          ),

        ),

      ),

    );

  }

}


