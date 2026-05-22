import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/addresses_repository.dart';
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
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPageScaffold(
      title: widget.selectMode
          ? context.tr('select_address', fallback: 'اختر عنواناً')
          : context.tr('addresses', fallback: 'العناوين'),
      onBack: () => Navigator.pop(context),
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
                                onTap: widget.selectMode
                                    ? () => Navigator.pop(context, a['id'] as int)
                                    : null,
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
