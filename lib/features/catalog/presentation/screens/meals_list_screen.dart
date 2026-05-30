import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_typography.dart';

import '../../../../core/widgets/error_view.dart';

import '../../../../core/widgets/figma_meal_row.dart';

import '../../../../core/widgets/app_page_scaffold.dart';

import '../../../../core/widgets/loading_view.dart';

import '../../../localization/presentation/extensions/translation_context.dart';

import '../../data/models/category_model.dart';

import '../../data/models/meal_model.dart';

import '../providers/home_provider.dart';

import 'meal_detail_screen.dart';



/// Figma — وجبات list for a category/subcategory.

class MealsListScreen extends StatefulWidget {

  const MealsListScreen({super.key, required this.category, this.subcategory});



  final CategoryModel category;

  final String? subcategory;



  @override

  State<MealsListScreen> createState() => _MealsListScreenState();

}



class _MealsListScreenState extends State<MealsListScreen> {

  List<MealModel> _meals = [];

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

      final meals = await context.read<HomeProvider>().loadMealsForCategory(

            widget.category.id,

            subcategory: widget.subcategory,

          );

      if (mounted) {

        setState(() {

          _meals = meals;

          _loading = false;

        });

      }

    } catch (e) {

      if (mounted) {

        setState(() {

          _error = e.toString();

          _loading = false;

        });

      }

    }

  }



  @override

  Widget build(BuildContext context) {

    final subtitle = widget.subcategory ?? widget.category.name;



    return AppPageScaffold(

      title: widget.category.name,

      body: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          Padding(

            padding: const EdgeInsets.fromLTRB(30, 8, 30, 0),

            child: Text(

              subtitle,

              textAlign: TextAlign.center,

              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),

            ),

          ),

          Expanded(

            child: _loading

                ? const LoadingView()

                : _error != null

                    ? ErrorView(message: _error!, onRetry: _load)

                    : _meals.isEmpty

                        ? Center(

                            child: Text(

                              context.tr('no_meals', fallback: 'لا توجد وجبات'),

                              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),

                            ),

                          )

                        : ListView.separated(

                            padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),

                            itemCount: _meals.length,

                            separatorBuilder: (_, _) => const SizedBox(height: 12),

                            itemBuilder: (_, i) {

                              final meal = _meals[i];

                              return FigmaMealRow(

                                name: meal.name,

                                price: '${meal.price.toStringAsFixed(2)} ${context.tr('currency', fallback: 'د.أ')}',

                                imageUrl: meal.image,

                                subtitle: meal.userName ?? context.tr('chef', fallback: 'طاهٍ'),

                                trailing: Row(

                                  mainAxisSize: MainAxisSize.min,

                                  children: [

                                    Container(

                                      width: 28,

                                      height: 28,

                                      decoration: const BoxDecoration(

                                        color: AppColors.primary,

                                        shape: BoxShape.circle,

                                      ),

                                      child: const Icon(Icons.add, color: Colors.white, size: 16),

                                    ),

                                    const SizedBox(width: 6),

                                    Text('30m', style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted)),

                                  ],

                                ),

                                onTap: () => Navigator.push(

                                  context,

                                  MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)),

                                ),

                              );

                            },

                          ),

          ),

        ],

      ),

    );

  }

}


