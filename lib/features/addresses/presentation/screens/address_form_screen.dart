import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/addresses_repository.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _name = TextEditingController();
  final _place = TextEditingController();
  final _neighborhood = TextEditingController();
  final _build = TextEditingController();
  final _floor = TextEditingController();
  final _apartment = TextEditingController();
  final _details = TextEditingController();
  int _countryId = 1;
  int _cityId = 1;
  double _lat = 0;
  double _lng = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
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
    setState(() {
      _lat = coords.lat;
      _lng = coords.lng;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AddressesRepository(context.read<ApiClient>()).create({
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    setState(() => _saving = false);
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.tr('new_address', fallback: 'عنوان جديد'),
      body: AppPageBody(
        child: ListView(
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    textAlign: TextAlign.right,
                    decoration: _fieldDecoration(context.tr('address_label', fallback: 'التسمية')),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _place,
                    textAlign: TextAlign.right,
                    decoration: _fieldDecoration(context.tr('place', fallback: 'المكان')),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _neighborhood,
                    textAlign: TextAlign.right,
                    decoration: _fieldDecoration(context.tr('neighborhood', fallback: 'الحي')),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _build,
                    textAlign: TextAlign.right,
                    decoration: _fieldDecoration(context.tr('building', fallback: 'المبنى')),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _floor,
                    textAlign: TextAlign.right,
                    decoration: _fieldDecoration(context.tr('floor', fallback: 'الطابق')),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _apartment,
                    textAlign: TextAlign.right,
                    decoration: _fieldDecoration(context.tr('apartment', fallback: 'الشقة')),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _details,
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    decoration: _fieldDecoration(context.tr('details', fallback: 'تفاصيل')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: context.tr('save', fallback: 'حفظ'),
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
