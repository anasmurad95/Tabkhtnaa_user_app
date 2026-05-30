import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../addresses/data/addresses_repository.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../widgets/password_reset_scaffold.dart';
import '../widgets/register_form_field.dart';
import 'register_payment_screen.dart';

/// Flow B step 1 — تحديد العنوان
class RegisterAddressScreen extends StatefulWidget {
  const RegisterAddressScreen({super.key});

  @override
  State<RegisterAddressScreen> createState() => _RegisterAddressScreenState();
}

class _RegisterAddressScreenState extends State<RegisterAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'المنزل');
  final _place = TextEditingController();
  final _neighborhood = TextEditingController();
  final _build = TextEditingController();
  final _floor = TextEditingController();
  final _apartment = TextEditingController();
  final _details = TextEditingController();

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _cities = [];
  int? _countryId;
  int? _cityId;
  double _lat = 0;
  double _lng = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCountries();
      _initLocation();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _place.dispose();
    _neighborhood.dispose();
    _build.dispose();
    _floor.dispose();
    _apartment.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final coords = await context.read<LocationService>().getCurrent();
    if (mounted) {
      setState(() {
        _lat = coords.lat;
        _lng = coords.lng;
      });
    }
  }

  Future<void> _loadCountries() async {
    final client = context.read<ApiClient>();
    final res = await client.dio.get('/countries');
    final data = res.data['data'] as List?;
    if (data == null || !mounted) return;

    final countries = data.cast<Map<String, dynamic>>();
    final jordan = countries.cast<Map<String, dynamic>?>().firstWhere(
          (c) => c?['iso2']?.toString().toUpperCase() == 'JO',
          orElse: () => countries.isNotEmpty ? countries.first : null,
        );
    final countryId = jordan?['id'] as int?;
    setState(() {
      _countries = countries;
      _countryId = countryId;
      _cities = _extractCities(jordan);
      _cityId = _cities.isNotEmpty ? _cities.first['id'] as int? : null;
    });
  }

  List<Map<String, dynamic>> _extractCities(Map<String, dynamic>? country) {
    final cities = country?['cities'];
    if (cities is List) return cities.cast<Map<String, dynamic>>();
    return [];
  }

  void _onCountryChanged(int? id) {
    final country = _countries.cast<Map<String, dynamic>?>().firstWhere(
          (c) => c?['id'] == id,
          orElse: () => null,
        );
    setState(() {
      _countryId = id;
      _cities = _extractCities(country);
      _cityId = _cities.isNotEmpty ? _cities.first['id'] as int? : null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _countryId == null || _cityId == null) return;

    setState(() => _loading = true);
    try {
      await context.read<AddressesRepository>().create({
        'name': _name.text.trim(),
        'place': _place.text.trim(),
        'country_id': _countryId,
        'city_id': _cityId,
        'neighborhood': _neighborhood.text.trim(),
        'build_address': _build.text.trim(),
        'floor': _floor.text.trim(),
        'apartment_address': _apartment.text.trim(),
        'details': _details.text.trim(),
        'latitude': _lat,
        'longitude': _lng,
      });
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterPaymentScreen()),
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
      step: 0,
      title: context.tr('set_address', fallback: 'تحديد العنوان'),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RegisterFormField(
                      label: context.tr('address_label', fallback: 'اسم العنوان'),
                      controller: _name,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterFormField(
                      label: context.tr('place', fallback: 'المكان'),
                      controller: _place,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterDropdownField<int>(
                      label: context.tr('country', fallback: 'الدولة'),
                      value: _countryId,
                      items: _countries
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id'] as int,
                              child: Text(c['native']?.toString() ?? c['iso2']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: _onCountryChanged,
                      validator: (v) => v == null ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterDropdownField<int>(
                      label: context.tr('city', fallback: 'المدينة'),
                      value: _cityId,
                      items: _cities
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['id'] as int,
                              child: Text(c['name']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _cityId = v),
                      validator: (v) => v == null ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterFormField(
                      label: context.tr('neighborhood', fallback: 'الحي'),
                      controller: _neighborhood,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterFormField(
                      label: context.tr('building', fallback: 'المبنى'),
                      controller: _build,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterFormField(
                      label: context.tr('floor', fallback: 'الطابق'),
                      controller: _floor,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterFormField(
                      label: context.tr('apartment', fallback: 'الشقة'),
                      controller: _apartment,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 12),
                    RegisterFormField(
                      label: context.tr('address_details', fallback: 'تفاصيل إضافية'),
                      controller: _details,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? context.tr('required', fallback: 'مطلوب') : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(
                        'location_auto_hint',
                        fallback: 'يتم تحديد الموقع الجغرافي تلقائياً من جهازك',
                      ),
                      textAlign: TextAlign.center,
                      style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
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
}
