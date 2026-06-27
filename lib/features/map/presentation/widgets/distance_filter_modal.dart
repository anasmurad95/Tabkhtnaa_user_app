import 'package:flutter/material.dart';



import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_typography.dart';

import '../../../localization/presentation/extensions/translation_context.dart';



/// Figma — distance filter overlay (0–93.3 km).

class DistanceFilterModal extends StatefulWidget {

  const DistanceFilterModal({super.key, required this.initialRadius});



  final double initialRadius;



  @override

  State<DistanceFilterModal> createState() => _DistanceFilterModalState();

}



class _DistanceFilterModalState extends State<DistanceFilterModal> {

  static const maxKm = 93.3;

  late double _radius;



  @override

  void initState() {

    super.initState();

    _radius = widget.initialRadius.clamp(0, maxKm);

  }



  @override

  Widget build(BuildContext context) {

    return Directionality(

      textDirection: TextDirection.rtl,

      child: Container(

        margin: const EdgeInsets.all(16),

        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            Text(

              context.tr('choose_distance', fallback: 'اختر المسافة'),

              textAlign: TextAlign.center,

              style: AppTypography.shamelBold(size: 14, color: AppColors.primary),

            ),

            const SizedBox(height: 24),

            Text(

              '${_radius.toStringAsFixed(1)} km',

              textAlign: TextAlign.center,

              style: AppTypography.shamelBold(size: 16),

            ),

            Slider(

              value: _radius,

              min: 0,

              max: maxKm,

              divisions: 100,

              activeColor: AppColors.primary,

              onChanged: (v) => setState(() => _radius = v),

            ),

            const SizedBox(height: 8),

            SizedBox(

              height: 40,

              child: ElevatedButton(

                onPressed: () => Navigator.pop(context, _radius),

                style: ElevatedButton.styleFrom(

                  backgroundColor: AppColors.primary,

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.5)),

                ),

                child: Text(

                  context.tr('choose_distance', fallback: 'اختر المسافة'),

                  style: AppTypography.shamelBold(size: 14, color: Colors.white),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}


