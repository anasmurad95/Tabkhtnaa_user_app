import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../addresses/presentation/screens/addresses_screen.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../catalog/data/models/meal_model.dart';
import '../providers/cart_provider.dart';
import 'payment_method_screen.dart';

/// Figma order meal form — delivery, time, address, payment, notes + green confirm bar.
class OrderMealScreen extends StatefulWidget {
  const OrderMealScreen({super.key, required this.meal, this.quantity = 1});

  final MealModel meal;
  final int quantity;

  @override
  State<OrderMealScreen> createState() => _OrderMealScreenState();
}

class _OrderMealScreenState extends State<OrderMealScreen> {
  String _delivery = 'delivery';
  String _payment = 'cash';
  int? _addressId;
  final _notes = TextEditingController();
  TimeOfDay _mealTime = TimeOfDay.now();
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  double get _subtotal => widget.meal.price * widget.quantity;
  double get _vat => _subtotal * 0.16;
  double get _deliveryFee => _delivery == 'delivery' ? 2.5 : 0;
  double get _total => _subtotal + _vat + _deliveryFee;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _mealTime);
    if (picked != null) setState(() => _mealTime = picked);
  }

  Future<void> _confirm() async {
    if (_addressId == null && _delivery == 'delivery') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('select_address', fallback: 'اختر عنواناً'))),
      );
      return;
    }
    setState(() => _submitting = true);
    final ok = await context.read<CartProvider>().add(
          makerId: widget.meal.userId!,
          mealId: widget.meal.id,
          quantity: widget.quantity,
          note: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('added_to_cart', fallback: 'أضيف للسلة'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.tr('order_meal', fallback: 'طلب وجبة'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 16, 30, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.meal.name, style: AppTypography.shamelBold(size: 16)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _delivery,
                    decoration: InputDecoration(labelText: context.tr('delivery_type', fallback: 'نوع التوصيل')),
                    items: [
                      DropdownMenuItem(value: 'delivery', child: Text(context.tr('delivery', fallback: 'توصيل'))),
                      DropdownMenuItem(value: 'pick_up', child: Text(context.tr('pick_up', fallback: 'استلام'))),
                    ],
                    onChanged: (v) => setState(() => _delivery = v ?? 'delivery'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('meal_time', fallback: 'وقت الوجبة'), style: AppTypography.shamelBold(size: 12)),
                    subtitle: Text(_mealTime.format(context)),
                    trailing: const Icon(Icons.access_time, color: AppColors.primary),
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('delivery_address', fallback: 'عنوان التوصيل'), style: AppTypography.shamelBold(size: 12)),
                    subtitle: Text(
                      _addressId == null
                          ? context.tr('tap_to_choose', fallback: 'اضغط للاختيار')
                          : '#$_addressId',
                    ),
                    trailing: const Icon(Icons.chevron_left, color: AppColors.primary),
                    onTap: () async {
                      final id = await Navigator.push<int>(
                        context,
                        MaterialPageRoute(builder: (_) => const AddressesScreen(selectMode: true)),
                      );
                      if (id != null) setState(() => _addressId = id);
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('payment_method', fallback: 'طريقة الدفع'), style: AppTypography.shamelBold(size: 12)),
                    subtitle: Text(_paymentLabel(_payment)),
                    trailing: const Icon(Icons.payment, color: AppColors.primary),
                    onTap: () async {
                      final method = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (_) => PaymentMethodScreen(initialMethod: _payment)),
                      );
                      if (method != null) setState(() => _payment = method);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: context.tr('notes', fallback: 'ملاحظات'),
                      hintText: context.tr('notes_hint', fallback: 'أي طلبات خاصة...'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.success,
            padding: const EdgeInsets.fromLTRB(30, 12, 30, 20),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('total', fallback: 'المجموع'),
                          style: AppTypography.shamelBook(size: 11, color: Colors.white70),
                        ),
                        Text(
                          '${_total.toStringAsFixed(2)} ${context.tr('currency', fallback: 'د.أ')}',
                          style: AppTypography.geBold(size: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.success,
                      ),
                      onPressed: _submitting ? null : _confirm,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.tr('confirm_order', fallback: 'تأكيد الطلب')),
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

  String _paymentLabel(String method) {
    switch (method) {
      case 'cards':
        return context.tr('card', fallback: 'بطاقة');
      case 'wallet':
        return context.tr('wallet', fallback: 'محفظة');
      default:
        return context.tr('cash', fallback: 'نقدي');
    }
  }
}
