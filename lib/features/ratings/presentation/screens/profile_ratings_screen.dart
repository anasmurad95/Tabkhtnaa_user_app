import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../orders/data/orders_repository.dart';
import 'submit_rating_screen.dart';

class ProfileRatingsScreen extends StatefulWidget {
  const ProfileRatingsScreen({super.key});

  @override
  State<ProfileRatingsScreen> createState() => _ProfileRatingsScreenState();
}

class _ProfileRatingsScreenState extends State<ProfileRatingsScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = OrdersRepository(context.read<ApiClient>());
      final all = await repo.listOrders();
      _orders = all.where((o) => o['status']?.toString() == 'delivered').toList();
    } catch (_) {
      _orders = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.tr('rating', fallback: 'التقييم'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? AppEmptyState(
                  message: context.tr('no_orders_to_rate', fallback: 'لا توجد طلبات مكتملة للتقييم'),
                  icon: Icons.star_outline,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
                  itemCount: _orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final order = _orders[i];
                    return AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${context.tr('order', fallback: 'طلب')} #${order['id']}',
                                  style: AppTypography.shamelBold(size: 14),
                                ),
                                Text(
                                  order['chef']?['name']?.toString() ?? '',
                                  style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final chefId = order['chef_id'] as int? ??
                                  (order['chef'] as Map?)?['id'] as int?;
                              if (chefId == null) {
                                AppToast.error(context, context.tr('action_failed', fallback: 'تعذر التقييم'));
                                return;
                              }
                              final rated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubmitRatingScreen(
                                    chefId: chefId,
                                    orderId: order['id'] as int,
                                  ),
                                ),
                              );
                              if (rated == true) {
                                AppToast.success(
                                  context,
                                  context.tr('rating_submitted', fallback: 'شكراً لتقييمك'),
                                );
                              }
                            },
                            child: Text(context.tr('rate', fallback: 'قيّم')),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
