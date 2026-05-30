import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/image_url.dart';
import '../../../../core/widgets/figma_meal_row.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/catalog_repository.dart';
import 'meal_detail_screen.dart';

/// Figma chef profile — header ratings, tabs: معلومات | قائمة طعام | تعليقات
class ChefDetailScreen extends StatefulWidget {
  const ChefDetailScreen({super.key, required this.chefId});

  final int chefId;

  @override
  State<ChefDetailScreen> createState() => _ChefDetailScreenState();
}

class _ChefDetailScreenState extends State<ChefDetailScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _chef;
  bool _loading = true;
  late TabController _tabs;
  String? _mealFilter;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await CatalogRepository(context.read<ApiClient>()).getChef(widget.chefId);
    setState(() {
      _chef = data;
      _loading = false;
    });
  }

  Future<void> _showFilter() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.tr('filter', fallback: 'تصفية'), style: AppTypography.shamelBold(size: 14)),
                const SizedBox(height: 12),
                _FilterChip(
                  label: context.tr('all', fallback: 'الكل'),
                  selected: _mealFilter == null,
                  onTap: () {
                    setState(() => _mealFilter = null);
                    Navigator.pop(ctx);
                  },
                ),
                _FilterChip(
                  label: context.tr('ready', fallback: 'جاهز'),
                  selected: _mealFilter == 'ready',
                  onTap: () {
                    setState(() => _mealFilter = 'ready');
                    Navigator.pop(ctx);
                  },
                ),
                _FilterChip(
                  label: context.tr('pre_order', fallback: 'طلب مسبق'),
                  selected: _mealFilter == 'pre-order',
                  onTap: () {
                    setState(() => _mealFilter = 'pre-order');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic>? get _raties => _chef?['raties'] as Map<String, dynamic>?;

  List<Map<String, dynamic>> get _meals {
    final all = (_chef?['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (_mealFilter == null) return all;
    return all.where((m) => m['type']?.toString() == _mealFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppPageScaffold(
        title: context.tr('chef', fallback: 'الشيف'),
        body: const LoadingView(),
      );
    }
    final chef = _chef!;

    return AppPageScaffold(
      title: chef['name']?.toString() ?? context.tr('chef', fallback: 'الشيف'),
      actions: [
        IconButton(onPressed: _showFilter, icon: const Icon(Icons.filter_list, color: Colors.white)),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: chef['profile_image'] != null
                      ? CachedNetworkImageProvider(resolveMediaUrl(chef['profile_image']?.toString()))
                      : const AssetImage(FigmaAssets.profileAvatarSample),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _RatingBox(
                      label: context.tr('speed', fallback: 'السرعة'),
                      value: _raties?['rating_speed_chef']?.toString() ?? '—',
                    ),
                    _RatingBox(
                      label: context.tr('service', fallback: 'الخدمة'),
                      value: _raties?['rating_delivery']?.toString() ?? '—',
                    ),
                    _RatingBox(
                      label: context.tr('taste', fallback: 'الطعم'),
                      value: _raties?['rating_speed']?.toString() ?? '—',
                    ),
                  ],
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: context.tr('info', fallback: 'معلومات')),
              Tab(text: context.tr('menu_list', fallback: 'قائمة طعام')),
              Tab(text: context.tr('comments', fallback: 'تعليقات')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _InfoTab(chef: chef, onChat: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        peerUserId: widget.chefId,
                        peerType: 'chef',
                        title: chef['name']?.toString(),
                      ),
                    ),
                  );
                }),
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
                  itemCount: _meals.length,
                  itemBuilder: (_, i) {
                    final m = _meals[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FigmaMealRow(
                        name: m['name']?.toString() ?? '',
                        price: '${m['price']}',
                        imageUrl: m['image']?.toString(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: m['id'] as int)),
                        ),
                      ),
                    );
                  },
                ),
                Center(
                  child: Text(
                    context.tr('no_comments', fallback: 'لا توجد تعليقات بعد'),
                    style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBox extends StatelessWidget {
  const _RatingBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.geBold(size: 16, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.chef, required this.onChat});

  final Map<String, dynamic> chef;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final addrList = chef['user_address'] ?? chef['userAddress'];
    final addr = (addrList as List?)?.cast<Map<String, dynamic>>().firstOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
      children: [
        Text(
          chef['name']?.toString() ?? '',
          style: AppTypography.shamelBold(size: 16),
        ),
        const SizedBox(height: 8),
        Text(
          addr?['place']?.toString() ?? context.tr('no_address', fallback: 'لا يوجد عنوان'),
          style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: ElevatedButton(onPressed: onChat, child: Text(context.tr('contact_chef', fallback: 'تواصل مع الشيف'))),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? AppColors.primary : AppColors.surface,
          foregroundColor: selected ? Colors.white : AppColors.textMuted,
        ),
        child: Text(label),
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
