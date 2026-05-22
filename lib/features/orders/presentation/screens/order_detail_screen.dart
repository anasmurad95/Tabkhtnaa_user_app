import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/orders_repository.dart';

/// Figma 8.x order details (0:2201, 0:2342, 0:2480)
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await OrdersRepository(context.read<ApiClient>()).getOrder(widget.orderId);
    setState(() {
      _order = data;
      _loading = false;
    });
  }

  Future<void> _cancel() async {
    await OrdersRepository(context.read<ApiClient>()).cancelOrder(widget.orderId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: LoadingView()));
    }
    final order = _order!;

    return FigmaPageScaffold(
      title: '${context.tr('order', fallback: 'طلب')} #${order['id']}',
      onBack: () => Navigator.pop(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _DetailRow(context.tr('status', fallback: 'الحالة'), order['status']?.toString() ?? ''),
            _DetailRow(context.tr('total', fallback: 'المجموع'), '${order['total']}'),
            _DetailRow(context.tr('payment', fallback: 'الدفع'), order['payment_method']?.toString() ?? ''),
            const Spacer(),
            if (order['status'] != 'cancel' && order['status'] != 'delivered')
              SizedBox(
                height: 40,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentRed,
                    side: const BorderSide(color: AppColors.accentRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pillButton)),
                  ),
                  child: Text(context.tr('cancel_order', fallback: 'إلغاء الطلب')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label, style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.shamelBold(size: 14)),
          ],
        ),
      ),
    );
  }
}
