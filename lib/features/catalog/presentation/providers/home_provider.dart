import 'package:flutter/foundation.dart';

import '../../../../core/services/location_service.dart';
import '../../data/catalog_repository.dart';
import '../../data/models/category_model.dart';
import '../../data/models/chef_model.dart';
import '../../data/models/meal_model.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider(this._catalog, this._location);

  final CatalogRepository _catalog;
  final LocationService _location;

  bool loading = false;
  String? error;
  List<CategoryModel> categories = [];
  List<MealModel> meals = [];
  List<ChefModel> chefs = [];
  int? selectedCategoryId;

  Future<void> loadHome({String? search}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final coords = await _location.getCurrent();
      categories = await _catalog.getCategories();
      meals = await _catalog.getMeals(
        lat: coords.lat,
        lng: coords.lng,
        categoryId: selectedCategoryId,
        search: search,
      );
      chefs = await _catalog.getChefs(
        lat: coords.lat,
        lng: coords.lng,
        search: search,
      );
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  void selectCategory(int? id) {
    selectedCategoryId = id;
    loadHome();
  }
}
