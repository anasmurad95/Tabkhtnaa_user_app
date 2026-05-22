import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/figma_bottom_nav.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../catalog/presentation/screens/chefs_screen.dart';
import '../../../catalog/presentation/screens/home_screen.dart';
import '../../../localization/presentation/providers/translation_provider.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// Main shell — Figma bottom nav: المزيد · الخريطة · المشتريات · الطهاة · التصنيفات
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 4;

  late final List<Widget> _pages = const [
    ProfileScreen(),
    MapScreen(),
    CartScreen(),
    ChefsScreen(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<TranslationProvider>();
    final labels = [
      l10n.tr('nav_more', fallback: 'المزيد'),
      l10n.tr('nav_map', fallback: 'الخريطة'),
      l10n.tr('nav_cart', fallback: 'المشتريات'),
      l10n.tr('nav_chefs', fallback: 'الطهاة'),
      l10n.tr('nav_categories', fallback: 'التصنيفات'),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
      ),
      bottomNavigationBar: FigmaBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        labels: labels,
      ),
    );
  }
}
