import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/figma_meal_row.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/home_provider.dart';
import 'chef_detail_screen.dart';

/// Figma الطهاة tab — chef list from API
class ChefsScreen extends StatefulWidget {
  const ChefsScreen({super.key});

  @override
  State<ChefsScreen> createState() => _ChefsScreenState();
}

class _ChefsScreenState extends State<ChefsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    return FigmaPageScaffold(
      title: context.tr('nav_chefs', fallback: 'الطهاة'),
      body: home.loading
          ? const LoadingView()
          : home.error != null
              ? ErrorView(message: home.error!, onRetry: home.loadHome)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 100),
                  itemCount: home.chefs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final chef = home.chefs[i];
                    return FigmaMealRow(
                      name: chef.name,
                      price: chef.distance != null ? '${chef.distance!.toStringAsFixed(1)} km' : '',
                      imageUrl: chef.profileImage,
                      subtitle: context.tr('local_chef', fallback: 'طاهٍ محلي'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChefDetailScreen(chefId: chef.id)),
                      ),
                    );
                  },
                ),
    );
  }
}
