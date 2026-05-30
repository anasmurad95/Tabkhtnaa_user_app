import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/figma_meal_row.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/cart_provider.dart';
import '../widgets/utensils_modal.dart';
import 'checkout_screen.dart';

/// Figma 8.x — سلة المشتريات (0:2094+)
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CartProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return AppPageScaffold(
      title: context.tr('cart_title', fallback: 'سلة المشتريات'),
      showBack: false,
      body: cart.loading
          ? const LoadingView()
          : cart.cart == null
              ? AppEmptyState(
                  message: cart.error ?? context.tr('cart_empty', fallback: 'السلة فارغة'),
                  icon: Icons.shopping_cart_outlined,
                  action: AppPrimaryButton(
                    label: context.tr('retry', fallback: 'إعادة المحاولة'),
                    onPressed: cart.load,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
                        itemCount: (cart.cart!['meals'] as List?)?.length ?? 0,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final item = (cart.cart!['meals'] as List)[i] as Map<String, dynamic>;
                          final meal = item['meal'] as Map<String, dynamic>? ?? {};
                          return FigmaMealRow(
                            name: meal['name']?.toString() ?? 'Meal',
                            price: '${meal['price'] ?? item['price'] ?? 0}',
                            subtitle: '${context.tr('qty', fallback: 'الكمية')}: ${item['quantity']}',
                            imageUrl: meal['image']?.toString(),
                            onDelete: () => cart.remove(item['id'] as int),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr('subtotal', fallback: 'المجموع الفرعي'), style: AppTypography.shamelBook(size: 12)),
                                Text('${cart.cart!['sub_total'] ?? cart.cart!['total'] ?? 0}'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr('vat', fallback: 'ضريبة'), style: AppTypography.shamelBook(size: 12)),
                                Text('${cart.cart!['tax'] ?? 0}'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr('delivery_fee', fallback: 'التوصيل'), style: AppTypography.shamelBook(size: 12)),
                                Text('${cart.cart!['delivery_fees'] ?? 0}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.tr('total', fallback: 'المجموع'), style: AppTypography.shamelBold(size: 14)),
                                Text(
                                  '${cart.cart!['total'] ?? 0}',
                                  style: AppTypography.geBold(size: 16, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppPrimaryButton(
                              label: context.tr('checkout', fallback: 'إتمام الطلب'),
                              onPressed: () async {
                                await showUtensilsModal(context);
                                if (!context.mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => CheckoutScreen(cart: cart.cart!)),
                                );
                              },
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
