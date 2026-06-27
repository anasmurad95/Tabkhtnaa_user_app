import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/image_url.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../cart/presentation/screens/order_meal_screen.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/catalog_repository.dart';
import '../../data/models/meal_model.dart';

/// Figma 4. Menu_Details (0:4258, 0:4148, 0:4096)
class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({
    super.key,
    required this.mealId,
    this.chefId,
  });

  final int mealId;
  final int? chefId;

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
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    }
    setState(() => _loading = false);
  }

  int? get _makerId => _meal?.userId ?? widget.chefId;

  MealModel? get _mealForOrder {
    final meal = _meal;
    final makerId = _makerId;
    if (meal == null || makerId == null) return null;
    if (meal.userId == makerId) return meal;
    return meal.withMakerId(makerId);
  }

  Future<void> _addToCart() async {
    final meal = _mealForOrder;
    if (meal == null) {
      AppToast.error(context, context.tr('add_failed', fallback: 'فشل الإضافة'));
      return;
    }
    final ok = await context.read<CartProvider>().add(
          makerId: meal.userId!,
          mealId: meal.id,
          quantity: _qty,
        );
    if (!mounted) return;
    if (ok) {
      AppToast.success(context, context.tr('added_to_cart', fallback: 'أضيف للسلة'));
    } else {
      AppToast.error(context, context.tr('add_failed', fallback: 'فشل الإضافة'));
    }
  }

  void _orderNow() {
    final meal = _mealForOrder;
    if (meal == null) {
      AppToast.error(context, context.tr('add_failed', fallback: 'فشل الإضافة'));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderMealScreen(meal: meal, quantity: _qty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppPageScaffold(
        title: context.tr('meal', fallback: 'وجبة'),
        body: const LoadingView(),
      );
    }
    if (_error != null || _meal == null) {
      return AppPageScaffold(
        title: context.tr('meal', fallback: 'وجبة'),
        body: AppEmptyState(
          message: _error ?? context.tr('not_found', fallback: 'غير موجود'),
          icon: Icons.restaurant_outlined,
        ),
      );
    }

    final meal = _meal!;

    return AppPageScaffold(
      title: meal.name,
      body: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: meal.image != null
                ? CachedNetworkImage(imageUrl: resolveMediaUrl(meal.image), fit: BoxFit.cover)
                : FigmaAssetImage(FigmaAssets.splashBgFood, fit: BoxFit.cover),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
              child: Column(
                children: [
                  AppPrimaryButton(
                    label: context.tr('add_to_cart', fallback: 'أضف للسلة'),
                    onPressed: _addToCart,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _orderNow,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text(context.tr('order_now', fallback: 'اطلب الآن')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
