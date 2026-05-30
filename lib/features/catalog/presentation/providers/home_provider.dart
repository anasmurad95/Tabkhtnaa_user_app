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
  double searchRadius = 30;
  LocationCoords? lastCoords;
  ChefModel? selectedMapChef;

  Future<void> loadHome({String? search}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final coords = await _location.getCurrent();
      lastCoords = coords;
      categories = await _catalog.getCategories();
      meals = await _catalog.getMeals(
        lat: coords.lat,
        lng: coords.lng,
        categoryId: selectedCategoryId,
        search: search,
        radius: searchRadius,
      );
      chefs = await _catalog.getChefs(
        lat: coords.lat,
        lng: coords.lng,
        search: search,
        radius: searchRadius,
      );
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      categories = await _catalog.getCategories();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadChefs({String? search}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final coords = lastCoords ?? await _location.getCurrent();
      lastCoords = coords;
      chefs = await _catalog.getChefs(
        lat: coords.lat,
        lng: coords.lng,
        search: search,
        radius: searchRadius,
      );
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<List<MealModel>> loadMealsForCategory(int categoryId, {String? subcategory}) async {
    final coords = lastCoords ?? await _location.getCurrent();
    lastCoords = coords;
    return _catalog.getMeals(
      lat: coords.lat,
      lng: coords.lng,
      categoryId: categoryId,
      search: subcategory,
      radius: searchRadius,
    );
  }

  void selectCategory(int? id) {
    selectedCategoryId = id;
    loadHome();
  }

  void setSearchRadius(double radius) {
    searchRadius = radius;
    notifyListeners();
  }

  void selectMapChef(ChefModel? chef) {
    selectedMapChef = chef;
    notifyListeners();
  }

  Map<String, List<ChefModel>> get chefsByLocation {
    final map = <String, List<ChefModel>>{};
    for (final chef in chefs) {
      map.putIfAbsent(chef.locationGroupKey, () => []).add(chef);
    }
    return map;
  }
}
