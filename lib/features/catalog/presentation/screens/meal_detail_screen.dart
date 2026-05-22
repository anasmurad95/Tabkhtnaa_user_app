import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/image_url.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/catalog_repository.dart';
import '../../data/models/meal_model.dart';

/// Figma 4. Menu_Details (0:4258, 0:4148, 0:4096)
class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.mealId});

  final int mealId;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealModel? _meal;
  bool _loading = true;
  String? _error;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = CatalogRepository(context.read<ApiClient>());
      _meal = await repo.getMeal(widget.mealId);
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _loading = false);
  }

  Future<void> _addToCart() async {
    final meal = _meal;
    if (meal?.userId == null) return;
    final ok = await context.read<CartProvider>().add(
          makerId: meal!.userId!,
          mealId: meal.id,
          quantity: _qty,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? context.tr('added_to_cart', fallback: 'أضيف للسلة') : context.tr('add_failed', fallback: 'فشل الإضافة'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: LoadingView()));
    }
    if (_error != null || _meal == null) {
      return FigmaPageScaffold(
        title: context.tr('meal', fallback: 'وجبة'),
        onBack: () => Navigator.pop(context),
        body: Center(child: Text(_error ?? 'Not found')),
      );
    }

    final meal = _meal!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: meal.image != null
                      ? CachedNetworkImage(imageUrl: resolveMediaUrl(meal.image), fit: BoxFit.cover)
                      : Image.asset(FigmaAssets.splashBgFood, fit: BoxFit.cover),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(FigmaAssets.profileBackWhite, width: 9, height: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 16, 30, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(meal.name, style: AppTypography.shamelBold(size: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${meal.price.toStringAsFixed(2)} ${context.tr('currency', fallback: 'د.أ')}',
                      style: AppTypography.geBold(size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('description', fallback: 'الوصف'),
                      style: AppTypography.shamelBold(size: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meal.description ?? '',
                      style: AppTypography.shamelBook(size: 12),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, 99)),
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                        ),
                        Text('$_qty', style: AppTypography.shamelBold(size: 16)),
                        IconButton(
                          onPressed: () => setState(() => _qty = (_qty + 1).clamp(1, 99)),
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(43, 0, 43, 24),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    child: Text(context.tr('add_to_cart', fallback: 'أضف للسلة')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
