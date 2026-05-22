import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../addresses/presentation/screens/addresses_screen.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../../orders/data/orders_repository.dart';

/// Figma 8.x checkout / payment (0:1861, 0:1973)
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart});

  final Map<String, dynamic> cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _payment = 'cash';
  String _delivery = 'delivery';
  int? _addressId;
  bool _submitting = false;

  Future<void> _placeOrder() async {
    if (_addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('select_address', fallback: 'اختر عنواناً'))),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await OrdersRepository(context.read<ApiClient>()).createOrder(
        chefId: widget.cart['maker_id'] as int,
        cartId: widget.cart['id'] as int,
        addressId: _addressId!,
        paymentMethod: _payment,
        deliveryType: _delivery,
      );
      if (!mounted) return;
      Navigator.popUntil(context, (r) => r.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('order_placed', fallback: 'تم إنشاء الطلب'))),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPageScaffold(
      title: context.tr('checkout', fallback: 'الدفع'),
      onBack: () => Navigator.pop(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('choose_payment', fallback: 'اختيار طريقة الدفع'),
              style: AppTypography.shamelBold(size: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _PaymentTile(
              label: context.tr('cash', fallback: 'نقدي'),
              selected: _payment == 'cash',
              onTap: () => setState(() => _payment = 'cash'),
            ),
            _PaymentTile(
              label: context.tr('wallet', fallback: 'محفظة'),
              selected: _payment == 'wallet',
              onTap: () => setState(() => _payment = 'wallet'),
            ),
            _PaymentTile(
              label: context.tr('card', fallback: 'بطاقة'),
              selected: _payment == 'cards',
              onTap: () => setState(() => _payment = 'cards'),
            ),
            const SizedBox(height: 20),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  side: const BorderSide(color: AppColors.border, width: 0.5),
                ),
                title: Text(context.tr('delivery_address', fallback: 'عنوان التوصيل'), style: AppTypography.shamelBold(size: 12)),
                subtitle: Text(
                  _addressId == null
                      ? context.tr('tap_to_choose', fallback: 'اضغط للاختيار')
                      : '#$_addressId',
                  style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                ),
                trailing: Image.asset(FigmaAssets.profileChevronOrange, width: 8, height: 8),
                onTap: () async {
                  final id = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressesScreen(selectMode: true)),
                  );
                  if (id != null) setState(() => _addressId = id);
                },
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _delivery,
              decoration: InputDecoration(labelText: context.tr('delivery_type', fallback: 'نوع التوصيل')),
              items: [
                DropdownMenuItem(value: 'delivery', child: Text(context.tr('delivery', fallback: 'توصيل'))),
                DropdownMenuItem(value: 'pick_up', child: Text(context.tr('pick_up', fallback: 'استلام'))),
              ],
              onChanged: (v) => setState(() => _delivery = v ?? 'delivery'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('total', fallback: 'المجموع'), style: AppTypography.shamelBold(size: 14)),
                Text(
                  '${widget.cart['total'] ?? 0}',
                  style: AppTypography.geBold(size: 18, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _submitting ? null : _placeOrder,
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(context.tr('place_order', fallback: 'تأكيد الطلب')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pillButton),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.pillButton),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.pillButton),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: AppTypography.shamelBold(size: 12, color: selected ? AppColors.primary : AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}
