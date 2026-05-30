import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../../core/widgets/figma_meal_row.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../catalog/data/models/chef_model.dart';
import '../../../catalog/presentation/providers/home_provider.dart';
import '../../../catalog/presentation/screens/chef_detail_screen.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../widgets/distance_filter_modal.dart';



/// Figma — الخريطة with chef markers and floating card.

class MapScreen extends StatefulWidget {

  const MapScreen({super.key});



  @override

  State<MapScreen> createState() => _MapScreenState();

}



class _MapScreenState extends State<MapScreen> {

  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<HomeProvider>().loadChefs();

    });

  }



  Future<void> _openDistanceFilter() async {

    final home = context.read<HomeProvider>();

    final radius = await showModalBottomSheet<double>(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) => DistanceFilterModal(initialRadius: home.searchRadius),

    );

    if (radius != null && mounted) {

      home.setSearchRadius(radius);

      await home.loadChefs();

    }

  }



  @override

  Widget build(BuildContext context) {

    final home = context.watch<HomeProvider>();

    final selected = home.selectedMapChef;

    final coords = home.lastCoords;



    return Directionality(

      textDirection: TextDirection.rtl,

      child: Scaffold(

        backgroundColor: AppColors.background,

        body: Stack(

          fit: StackFit.expand,

          children: [

            if (home.loading)

              const LoadingView()

            else if (home.error != null)

              ErrorView(message: home.error!, onRetry: home.loadChefs)

            else

              _MapCanvas(

                chefs: home.chefs,

                centerLat: coords?.lat ?? 31.9539,

                centerLng: coords?.lng ?? 35.9106,

                selectedChef: selected,

                onChefTap: home.selectMapChef,

              ),

            SafeArea(

              child: Column(

                children: [

                  _MapHeader(onFilter: _openDistanceFilter),

                ],

              ),

            ),

            if (selected != null)

              Positioned(

                left: 20,

                right: 20,

                bottom: 100,

                child: _FloatingChefCard(

                  chef: selected,

                  onTap: () => Navigator.push(

                    context,

                    MaterialPageRoute(builder: (_) => ChefDetailScreen(chefId: selected.id)),

                  ),

                  onClose: () => home.selectMapChef(null),

                ),

              ),

          ],

        ),

      ),

    );

  }

}



class _MapHeader extends StatelessWidget {

  const _MapHeader({required this.onFilter});



  final VoidCallback onFilter;



  @override

  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.all(12),

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      decoration: BoxDecoration(

        color: AppColors.primary,

        borderRadius: BorderRadius.circular(AppRadii.pillButton),

      ),

      child: Row(

        children: [

          InkWell(

            onTap: onFilter,

            child: const Icon(Icons.tune, color: Colors.white, size: 20),

          ),

          Expanded(

            child: Text(

              context.tr('nav_map', fallback: 'الخريطة'),

              textAlign: TextAlign.center,

              style: AppTypography.shamelBold(size: 14, color: Colors.white),

            ),

          ),

          FigmaAssetImage(FigmaAssets.globeWhite, width: 20, height: 20),

        ],

      ),

    );

  }

}



class _MapCanvas extends StatelessWidget {

  const _MapCanvas({

    required this.chefs,

    required this.centerLat,

    required this.centerLng,

    required this.selectedChef,

    required this.onChefTap,

  });



  final List<ChefModel> chefs;

  final double centerLat;

  final double centerLng;

  final ChefModel? selectedChef;

  final ValueChanged<ChefModel> onChefTap;



  @override

  Widget build(BuildContext context) {

    return LayoutBuilder(

      builder: (context, constraints) {

        return CustomPaint(

          painter: _MapGridPainter(),

          child: Stack(

            children: [

              for (final chef in chefs)

                if (chef.latitude != null && chef.longitude != null)

                  _ChefMarker(

                    left: _lngToX(chef.longitude!, centerLng, constraints.maxWidth),

                    top: _latToY(chef.latitude!, centerLat, constraints.maxHeight),

                    selected: selectedChef?.id == chef.id,

                    onTap: () => onChefTap(chef),

                  ),

            ],

          ),

        );

      },

    );

  }



  double _lngToX(double lng, double centerLng, double width) {

    final delta = (lng - centerLng) * 8000;

    return (width / 2 + delta).clamp(24.0, width - 24);

  }



  double _latToY(double lat, double centerLat, double height) {

    final delta = (centerLat - lat) * 8000;

    return (height / 2 + delta).clamp(80.0, height - 160);

  }

}



class _ChefMarker extends StatelessWidget {

  const _ChefMarker({

    required this.left,

    required this.top,

    required this.selected,

    required this.onTap,

  });



  final double left;

  final double top;

  final bool selected;

  final VoidCallback onTap;



  @override

  Widget build(BuildContext context) {

    return Positioned(

      left: left,

      top: top,

      child: GestureDetector(

        onTap: onTap,

        child: Column(

          children: [

            Container(

              width: selected ? 36 : 28,

              height: selected ? 36 : 28,

              decoration: BoxDecoration(

                color: AppColors.primary,

                shape: BoxShape.circle,

                border: Border.all(color: Colors.white, width: 2),

                boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 4)],

              ),

              child: const Icon(Icons.restaurant, color: Colors.white, size: 16),

            ),

            if (selected)

              Container(

                margin: const EdgeInsets.only(top: 2),

                width: 8,

                height: 8,

                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),

              ),

          ],

        ),

      ),

    );

  }

}



class _MapGridPainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final bg = Paint()..color = const Color(0xFFE8ECF0);

    canvas.drawRect(Offset.zero & size, bg);



    final grid = Paint()

      ..color = const Color(0xFFD0D5DC)

      ..strokeWidth = 0.5;

    const step = 40.0;

    for (var x = 0.0; x < size.width; x += step) {

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);

    }

    for (var y = 0.0; y < size.height; y += step) {

      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);

    }



    final center = Paint()..color = AppColors.primary.withValues(alpha: 0.2);

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 60, center);

  }



  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}



class _FloatingChefCard extends StatelessWidget {

  const _FloatingChefCard({

    required this.chef,

    required this.onTap,

    required this.onClose,

  });



  final ChefModel chef;

  final VoidCallback onTap;

  final VoidCallback onClose;



  @override

  Widget build(BuildContext context) {

    return Material(

      elevation: 8,

      borderRadius: BorderRadius.circular(AppRadii.md),

      child: Stack(

        children: [

          FigmaMealRow(

            name: chef.name,

            price: chef.distance != null ? '${chef.distance!.toStringAsFixed(1)} km' : '',

            imageUrl: chef.profileImage,

            subtitle: context.tr('local_chef', fallback: 'طاهٍ محلي'),

            onTap: onTap,

          ),

          Positioned(

            top: 4,

            left: 4,

            child: IconButton(

              icon: const Icon(Icons.close, size: 18),

              onPressed: onClose,

            ),

          ),

        ],

      ),

    );

  }

}


