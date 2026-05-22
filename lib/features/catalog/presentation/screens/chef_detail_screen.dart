import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/image_url.dart';
import '../../../../core/widgets/figma_meal_row.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/catalog_repository.dart';
import 'meal_detail_screen.dart';

/// Figma 9.x food / chef (0:2, 0:368, …)
class ChefDetailScreen extends StatefulWidget {
  const ChefDetailScreen({super.key, required this.chefId});

  final int chefId;

  @override
  State<ChefDetailScreen> createState() => _ChefDetailScreenState();
}

class _ChefDetailScreenState extends State<ChefDetailScreen> {
  Map<String, dynamic>? _chef;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await CatalogRepository(context.read<ApiClient>()).getChef(widget.chefId);
    setState(() {
      _chef = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: LoadingView()));
    }
    final chef = _chef!;
    final meals = (chef['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return FigmaPageScaffold(
      title: chef['name']?.toString() ?? context.tr('chef', fallback: 'الشيف'),
      onBack: () => Navigator.pop(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: chef['profile_image'] != null
                  ? CachedNetworkImageProvider(resolveMediaUrl(chef['profile_image']?.toString()))
                  : const AssetImage(FigmaAssets.profileAvatarSample),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('menu_list', fallback: 'قائمة طعام'),
            style: AppTypography.shamelBold(size: 14, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          ...meals.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FigmaMealRow(
                name: m['name']?.toString() ?? '',
                price: '${m['price']}',
                imageUrl: m['image']?.toString(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: m['id'] as int)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
