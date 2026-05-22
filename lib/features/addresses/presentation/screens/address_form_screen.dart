import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/location_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New address')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Label')),
          TextField(controller: _place, decoration: const InputDecoration(labelText: 'Place')),
          TextField(controller: _neighborhood, decoration: const InputDecoration(labelText: 'Neighborhood')),
          TextField(controller: _build, decoration: const InputDecoration(labelText: 'Building')),
          TextField(controller: _floor, decoration: const InputDecoration(labelText: 'Floor')),
          TextField(controller: _apartment, decoration: const InputDecoration(labelText: 'Apartment')),
          TextField(controller: _details, decoration: const InputDecoration(labelText: 'Details')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const CircularProgressIndicator() : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
