import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/figma_meal_row.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../ratings/presentation/screens/submit_rating_screen.dart';
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
  bool _cancelling = false;
  String? _error;

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
      final data = await OrdersRepository(context.read<ApiClient>()).getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, e.toString());
      setState(() => _error = e.toString());
    }
  }

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await OrdersRepository(context.read<ApiClient>()).cancelOrder(widget.orderId);
      if (!mounted) return;
      AppToast.success(
        context,
        context.tr('order_cancelled', fallback: 'تم إلغاء الطلب'),
      );
      await _load();
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppPageScaffold(
        title: context.tr('order', fallback: 'طلب'),
        body: const LoadingView(),
      );
    }
    if (_error != null || _order == null) {
      return AppPageScaffold(
        title: context.tr('order', fallback: 'طلب'),
        body: AppEmptyState(
          message: _error ?? context.tr('not_found', fallback: 'غير موجود'),
          icon: Icons.receipt_long_outlined,
          action: AppPrimaryButton(
            label: context.tr('retry', fallback: 'إعادة المحاولة'),
            onPressed: _load,
          ),
        ),
      );
    }

    final order = _order!;
    final meals = _orderMeals(order);
    final address = _nestedMap(order['address']);
    final chef = _nestedMap(order['chef']);
    final status = order['status']?.toString() ?? '';
    final canCancel = status != 'cancel' && status != 'delivered';
    final canRate = status == 'delivered';
    final chefId = order['chef_id'] as int? ?? (chef?['id'] as int?);

    return AppPageScaffold(
      title: '${context.tr('order', fallback: 'طلب')} #${order['id']}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusCard(status: _statusLabel(context, status), rawStatus: status),
            const SizedBox(height: 20),
            AppSectionTitle(context.tr('order_info', fallback: 'معلومات الطلب')),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _InfoRow(
                    label: context.tr('order_date', fallback: 'تاريخ الطلب'),
                    value: _formatDate(order['created_at']),
                  ),
                  if (order['delivery_type'] != null) ...[
                    const Divider(height: 20, color: AppColors.border),
                    _InfoRow(
                      label: context.tr('delivery_type', fallback: 'نوع التوصيل'),
                      value: _deliveryLabel(context, order['delivery_type']?.toString()),
                    ),
                  ],
                  const Divider(height: 20, color: AppColors.border),
                  _InfoRow(
                    label: context.tr('payment', fallback: 'الدفع'),
                    value: _paymentLabel(context, order['payment_method']?.toString()),
                  ),
                ],
              ),
            ),
            if (chef != null) ...[
              const SizedBox(height: 20),
              AppSectionTitle(context.tr('chef', fallback: 'الشيف')),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        (chef['name']?.toString().isNotEmpty == true ? chef['name'].toString()[0] : '?').toUpperCase(),
                        style: AppTypography.shamelBold(size: 14, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            chef['name']?.toString() ?? context.tr('chef', fallback: 'الشيف'),
                            style: AppTypography.shamelBold(size: 14),
                          ),
                          if (chef['phone'] != null)
                            Text(
                              chef['phone'].toString(),
                              style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            AppSectionTitle(context.tr('order_items', fallback: 'الوجبات')),
            if (meals.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Text(
                  context.tr('no_items', fallback: 'لا توجد وجبات'),
                  textAlign: TextAlign.center,
                  style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                ),
              )
            else
              ...meals.map((meal) {
                final additions = _relationList(meal['additions']);
                final accessories = _relationList(meal['accessories']);
                final extras = [
                  ...additions.map((a) => a['name']?.toString() ?? ''),
                  ...accessories.map((a) => a['name']?.toString() ?? a['default_name']?.toString() ?? ''),
                ].where((e) => e.isNotEmpty).join(' · ');
                final qty = meal['quantity'] ?? 1;
                final subtitle = [
                  '${context.tr('qty', fallback: 'الكمية')}: $qty',
                  if (extras.isNotEmpty) extras,
                ].join(' · ');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FigmaMealRow(
                    name: meal['meal_name']?.toString() ?? context.tr('meal', fallback: 'وجبة'),
                    price: '${meal['total'] ?? meal['price'] ?? 0}',
                    subtitle: subtitle,
                    imageUrl: _nestedMap(meal['meal'])?['image']?.toString(),
                  ),
                );
              }),
            if (address != null) ...[
              const SizedBox(height: 8),
              AppSectionTitle(context.tr('delivery_address', fallback: 'عنوان التوصيل')),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatAddress(address),
                        textAlign: TextAlign.right,
                        style: AppTypography.shamelBook(size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (order['details']?.toString().isNotEmpty == true) ...[
              const SizedBox(height: 20),
              AppSectionTitle(context.tr('notes', fallback: 'ملاحظات')),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Text(
                  order['details'].toString(),
                  textAlign: TextAlign.right,
                  style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                ),
              ),
            ],
            const SizedBox(height: 20),
            AppSectionTitle(context.tr('payment_summary', fallback: 'ملخص الدفع')),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _SummaryRow(
                    label: context.tr('subtotal', fallback: 'المجموع الفرعي'),
                    value: '${order['sub_total'] ?? 0}',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: context.tr('vat', fallback: 'ضريبة'),
                    value: '${order['tax'] ?? 0}',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: context.tr('delivery_fee', fallback: 'التوصيل'),
                    value: '${order['delivery_fees'] ?? 0}',
                  ),
                  if ((order['discount'] ?? 0) != 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: context.tr('discount', fallback: 'خصم'),
                      value: '-${order['discount']}',
                      valueColor: AppColors.accentRed,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _SummaryRow(
                    label: context.tr('total', fallback: 'المجموع'),
                    value: '${order['total'] ?? 0}',
                    bold: true,
                  ),
                ],
              ),
            ),
            if (canRate && chefId != null) ...[
              const SizedBox(height: 16),
              AppPrimaryButton(
                label: context.tr('rate_order', fallback: 'تقييم الطلب'),
                onPressed: () async {
                  final rated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubmitRatingScreen(
                        chefId: chefId,
                        orderId: widget.orderId,
                      ),
                    ),
                  );
                  if (rated == true && context.mounted) {
                    AppToast.success(
                      context,
                      context.tr('rating_submitted', fallback: 'شكراً لتقييمك'),
                    );
                  }
                },
              ),
            ],
            if (canCancel) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cancelling ? null : _cancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentRed,
                    side: const BorderSide(color: AppColors.accentRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _cancelling
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentRed),
                        )
                      : Text(context.tr('cancel_order', fallback: 'إلغاء الطلب')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

List<Map<String, dynamic>> _orderMeals(Map<String, dynamic> order) {
  final raw = order['order_meal'] ?? order['orderMeal'];
  if (raw is List) {
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  return [];
}

List<Map<String, dynamic>> _relationList(dynamic raw) {
  if (raw is List) {
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  return [];
}

Map<String, dynamic>? _nestedMap(dynamic raw) {
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return null;
}

String _formatAddress(Map<String, dynamic> address) {
  final parts = <String>[
    if (address['name']?.toString().isNotEmpty == true) address['name'].toString(),
    if (address['place']?.toString().isNotEmpty == true) address['place'].toString(),
    if (address['neighborhood']?.toString().isNotEmpty == true) address['neighborhood'].toString(),
    if (address['build_address']?.toString().isNotEmpty == true) address['build_address'].toString(),
    if (address['floor'] != null && address['floor'].toString().isNotEmpty) 'الطابق ${address['floor']}',
    if (address['apartment_address']?.toString().isNotEmpty == true) address['apartment_address'].toString(),
    if (address['details']?.toString().isNotEmpty == true) address['details'].toString(),
  ];
  return parts.join(' · ');
}

String _formatDate(dynamic raw) {
  if (raw == null) return '—';
  final dt = DateTime.tryParse(raw.toString());
  if (dt == null) return raw.toString();
  return DateFormat('yyyy/MM/dd · HH:mm', 'ar').format(dt.toLocal());
}

String _statusLabel(BuildContext context, String status) {
  return switch (status) {
    'pending' => context.tr('status_pending', fallback: 'قيد الانتظار'),
    'prepare' => context.tr('status_prepare', fallback: 'قيد التحضير'),
    'prepared' => context.tr('status_prepared', fallback: 'تم التجهيز'),
    'on_way' => context.tr('status_on_way', fallback: 'في الطريق'),
    'delivered' => context.tr('status_delivered', fallback: 'تم التوصيل'),
    'cancel' => context.tr('status_cancelled', fallback: 'ملغى'),
    'rejected' => context.tr('status_rejected', fallback: 'مرفوض'),
    _ => status,
  };
}

String _paymentLabel(BuildContext context, String? method) {
  return switch (method) {
    'cash' => context.tr('cash', fallback: 'نقدي'),
    'wallet' => context.tr('wallet', fallback: 'محفظة'),
    'cards' || 'card' => context.tr('card', fallback: 'بطاقة'),
    _ => method ?? '—',
  };
}

String _deliveryLabel(BuildContext context, String? type) {
  return switch (type) {
    'delivery' => context.tr('delivery', fallback: 'توصيل'),
    'pick_up' => context.tr('pick_up', fallback: 'استلام'),
    _ => type ?? '—',
  };
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.rawStatus});

  final String status;
  final String rawStatus;

  Color get _color => switch (rawStatus) {
        'delivered' => const Color(0xFF2EAF7D),
        'cancel' || 'rejected' => AppColors.accentRed,
        'on_way' || 'prepared' => const Color(0xFF1E9BD7),
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(status, style: AppTypography.shamelBold(size: 12, color: _color)),
          ),
          const Spacer(),
          Text(
            context.tr('status', fallback: 'الحالة'),
            style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: AppTypography.shamelBold(size: 12)),
        Text(label, style: AppTypography.shamelBook(size: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTypography.shamelBold(size: 14, color: valueColor ?? AppColors.primary)
        : AppTypography.shamelBook(size: 12, color: valueColor);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: style),
        Text(label, style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
