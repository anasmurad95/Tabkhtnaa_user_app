import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/addresses_repository.dart';
import '../widgets/address_modals.dart';
import 'address_form_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
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
      _items = await AddressesRepository(context.read<ApiClient>()).list();
    } catch (e) {
      _error = e.toString();
      if (mounted) {
        AppToast.error(context, e.toString());
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: widget.selectMode
          ? context.tr('select_address', fallback: 'اختر عنواناً')
          : context.tr('addresses', fallback: 'العناوين'),
      body: Stack(
        children: [
          _loading
              ? const LoadingView()
              : _error != null
                  ? Center(child: Text(_error!, style: AppTypography.shamelBook(size: 12)))
                  : _items.isEmpty
                      ? Center(
                          child: Text(
                            context.tr('no_addresses', fallback: 'لا توجد عناوين'),
                            style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(30, 16, 30, 80),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final a = _items[i];
                            final lat = double.tryParse(a['latitude']?.toString() ?? '');
                            final lng = double.tryParse(a['longitude']?.toString() ?? '');
                            return Material(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                  side: const BorderSide(color: AppColors.border, width: 0.5),
                                ),
                                title: Text(a['name']?.toString() ?? 'Address', style: AppTypography.shamelBold(size: 12)),
                                subtitle: Text(a['place']?.toString() ?? '', style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted)),
                                trailing: widget.selectMode
                                    ? const Icon(Icons.check_circle_outline, color: AppColors.primary)
                                    : PopupMenuButton<String>(
                                        onSelected: (v) async {
                                          if (v == 'map') {
                                            await showChefAddressMapModal(
                                              context,
                                              chefName: a['name']?.toString() ?? '',
                                              address: a['place']?.toString() ?? '',
                                              lat: lat,
                                              lng: lng,
                                            );
                                          } else if (v == 'delete') {
                                            final ok = await showDeleteAddressConfirm(context);
                                            if (ok && mounted) {
                                              try {
                                                await AddressesRepository(context.read<ApiClient>()).delete(a['id'] as int);
                                                if (!mounted) return;
                                                AppToast.success(
                                                  context,
                                                  context.tr('address_deleted', fallback: 'تم حذف العنوان'),
                                                );
                                                _load();
                                              } catch (e) {
                                                if (mounted) {
                                                  AppToast.error(context, e.toString());
                                                }
                                              }
                                            }
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          PopupMenuItem(value: 'map', child: Text(context.tr('show_map', fallback: 'عرض على الخريطة'))),
                                          PopupMenuItem(value: 'delete', child: Text(context.tr('delete', fallback: 'حذف'))),
                                        ],
                                      ),
                                onTap: widget.selectMode
                                    ? () => Navigator.pop(context, a['id'] as int)
                                    : () => showChefAddressMapModal(
                                          context,
                                          chefName: a['name']?.toString() ?? '',
                                          address: a['place']?.toString() ?? '',
                                          lat: lat,
                                          lng: lng,
                                        ),
                              ),
                            );
                          },
                        ),
          Positioned(
            left: 24,
            bottom: 24,
            child: FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressFormScreen()));
                _load();
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
