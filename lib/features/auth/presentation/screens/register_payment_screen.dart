import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/bank_info_repository.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../widgets/password_reset_scaffold.dart';
import '../widgets/register_form_field.dart';
import 'register_terms_screen.dart';

/// Flow B step 2 — طريقة الدفع
class RegisterPaymentScreen extends StatefulWidget {
  const RegisterPaymentScreen({super.key});

  @override
  State<RegisterPaymentScreen> createState() => _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState extends State<RegisterPaymentScreen> {
  static const _cardTab = 0;

  final _formKey = GlobalKey<FormState>();
  final _cardHolder = TextEditingController();
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _bankName = TextEditingController();
  final _iban = TextEditingController();
  final _swift = TextEditingController();

  int _tab = _cardTab;
  int? _countryId;
  int? _cityId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDefaultCountry());
  }

  @override
  void dispose() {
    _cardHolder.dispose();
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _bankName.dispose();
    _iban.dispose();
    _swift.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultCountry() async {
    final client = context.read<ApiClient>();
    final res = await client.dio.get('/countries');
    final data = res.data['data'] as List?;
    if (data == null || !mounted) return;

    final countries = data.cast<Map<String, dynamic>>();
    final jordan = countries.cast<Map<String, dynamic>?>().firstWhere(
          (c) => c?['iso2']?.toString().toUpperCase() == 'JO',
          orElse: () => countries.isNotEmpty ? countries.first : null,
        );
    final cities = jordan?['cities'];
    setState(() {
      _countryId = jordan?['id'] as int?;
      if (cities is List && cities.isNotEmpty) {
        _cityId = cities.first['id'] as int?;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _countryId == null || _cityId == null) return;

    setState(() => _loading = true);
    try {
      final payload = _tab == _cardTab
          ? {
              'country_id': _countryId,
              'city_id': _cityId,
              'type': 'bank',
              'bank_name': _cardHolder.text.trim(),
              'iban': _cardNumber.text.trim(),
              'swift_code': _cvv.text.trim().isNotEmpty ? _cvv.text.trim() : '0',
              'details': 'expiry:${_expiry.text.trim()}',
            }
          : {
              'country_id': _countryId,
              'city_id': _cityId,
              'type': 'bank',
              'bank_name': _bankName.text.trim(),
              'iban': _iban.text.trim(),
              'swift_code': _swift.text.trim(),
            };

      await context.read<BankInfoRepository>().create(payload);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterTermsScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PasswordResetScaffold(
      step: 1,
      title: context.tr('payment_method', fallback: 'طريقة الدفع'),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PaymentTabs(
              selected: _tab,
              onChanged: (v) => setState(() => _tab = v),
              cardLabel: context.tr('credit_card', fallback: 'بطاقة'),
              bankLabel: context.tr('bank_transfer', fallback: 'حساب بنكي'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _tab == _cardTab ? _buildCardFields(context) : _buildBankFields(context),
              ),
            ),
            PasswordResetPrimaryButton(
              label: context.tr('next', fallback: 'التالي'),
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFields(BuildContext context) {
    return Column(
      children: [
        RegisterFormField(
          label: context.tr('card_holder', fallback: 'اسم حامل البطاقة'),
          controller: _cardHolder,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
        ),
        const SizedBox(height: 12),
        RegisterFormField(
          label: context.tr('card_number', fallback: 'رقم البطاقة'),
          controller: _cardNumber,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().length < 12) {
              return context.tr('invalid_card', fallback: 'رقم بطاقة غير صالح');
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        RegisterFormField(
          label: context.tr('expiry_date', fallback: 'تاريخ الانتهاء'),
          controller: _expiry,
          keyboardType: TextInputType.datetime,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
        ),
        const SizedBox(height: 12),
        RegisterFormField(
          label: context.tr('cvv', fallback: 'CVV'),
          controller: _cvv,
          keyboardType: TextInputType.number,
          validator: (v) =>
              v == null || v.trim().length < 3 ? context.tr('required', fallback: 'مطلوب') : null,
        ),
      ],
    );
  }

  Widget _buildBankFields(BuildContext context) {
    return Column(
      children: [
        RegisterFormField(
          label: context.tr('bank_name', fallback: 'اسم البنك'),
          controller: _bankName,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
        ),
        const SizedBox(height: 12),
        RegisterFormField(
          label: context.tr('iban', fallback: 'IBAN'),
          controller: _iban,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
        ),
        const SizedBox(height: 12),
        RegisterFormField(
          label: context.tr('swift_code', fallback: 'SWIFT'),
          controller: _swift,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
        ),
      ],
    );
  }
}

class _PaymentTabs extends StatelessWidget {
  const _PaymentTabs({
    required this.selected,
    required this.onChanged,
    required this.cardLabel,
    required this.bankLabel,
  });

  final int selected;
  final ValueChanged<int> onChanged;
  final String cardLabel;
  final String bankLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: cardLabel,
              selected: selected == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: bankLabel,
              selected: selected == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.shamelBold(
              size: 12,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
