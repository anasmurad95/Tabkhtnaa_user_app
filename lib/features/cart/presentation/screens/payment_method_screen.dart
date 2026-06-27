import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../auth/data/bank_info_repository.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Figma payment selection — cash / card / other + card form.
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key, this.initialMethod = 'cash'});

  final String initialMethod;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late String _method;
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _method = widget.initialMethod;
  }

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (_method != 'cards') {
      Navigator.pop(context, _method);
      return;
    }
    setState(() => _saving = true);
    try {
      await BankInfoRepository(context.read<ApiClient>()).create({
        'card_holder_name': _holder.text.trim(),
        'card_number': _number.text.trim(),
        'expiry_date': _expiry.text.trim(),
        'cvv': _cvv.text.trim(),
      });
      if (mounted) {
        AppToast.success(context, context.tr('payment_saved', fallback: 'تم حفظ طريقة الدفع'));
        Navigator.pop(context, _method);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.tr('choose_payment', fallback: 'اختيار طريقة الدفع'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MethodTile(
              label: context.tr('cash', fallback: 'نقدي'),
              selected: _method == 'cash',
              onTap: () => setState(() => _method = 'cash'),
            ),
            _MethodTile(
              label: context.tr('card', fallback: 'بطاقة'),
              selected: _method == 'cards',
              onTap: () => setState(() => _method = 'cards'),
            ),
            _MethodTile(
              label: context.tr('wallet', fallback: 'محفظة'),
              selected: _method == 'wallet',
              onTap: () => setState(() => _method = 'wallet'),
            ),
            if (_method == 'cards') ...[
              const SizedBox(height: 20),
              Text(
                context.tr('add_new_card', fallback: 'اضافة كرت جديد'),
                style: AppTypography.shamelBold(size: 14, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _holder,
                decoration: InputDecoration(labelText: context.tr('card_holder', fallback: 'اسم حامل البطاقة')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _number,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: context.tr('card_number', fallback: 'رقم البطاقة')),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiry,
                      decoration: InputDecoration(labelText: context.tr('expiry', fallback: 'الصلاحية')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvv,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CVV'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveCard,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(context.tr('confirm', fallback: 'تأكيد')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.label, required this.selected, required this.onTap});

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
