import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/orders_provider.dart';
import 'order_detail_screen.dart';

/// Figma 8.x orders list
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<OrdersProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();

    return AppPageScaffold(
      title: context.tr('my_orders', fallback: 'طلباتي'),
      body: orders.loading
          ? const LoadingView()
          : orders.error != null
              ? ErrorView(message: orders.error!, onRetry: orders.load)
              : orders.orders.isEmpty
                  ? AppEmptyState(
                      message: context.tr('no_orders', fallback: 'لا توجد طلبات'),
                      icon: Icons.receipt_long_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: orders.orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final o = orders.orders[i];
                        return AppCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o['id'] as int)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Text(
                                '${o['total'] ?? 0}',
                                style: AppTypography.geBold(size: 14, color: AppColors.primary),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${context.tr('order', fallback: 'طلب')} #${o['id']}',
                                    style: AppTypography.shamelBold(size: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    o['status']?.toString() ?? '',
                                    style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
