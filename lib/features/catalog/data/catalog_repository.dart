import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';
import 'models/category_model.dart';
import 'models/chef_model.dart';
import 'models/meal_model.dart';

class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  Future<List<CategoryModel>> getCategories() async {
    final res = await _client.dio.get('/category/list');
    return _parseList(res.data, CategoryModel.fromJson);
  }

  Future<List<MealModel>> getMeals({
    required double lat,
    required double lng,
    int? categoryId,
    String? search,
  }) async {
    final res = await _client.dio.get('/user/meals/list', queryParameters: {
      'lat': lat,
      'long': lng,
      'radius': 30,
      if (categoryId != null) 'category_id': categoryId,
      if (search != null && search.isNotEmpty) 'chafe_name': search,
    });
    return _parsePaginated(res.data, MealModel.fromJson);
  }

  Future<MealModel> getMeal(int id) async {
    final res = await _client.dio.get('/user/meals/get', queryParameters: {'id': id});
    final parsed = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      parser: (v) => MealModel.fromJson(v as Map<String, dynamic>),
    );
    if (!parsed.status || parsed.data == null) {
      throw ApiException(parsed.errorMsg ?? 'Meal not found');
    }
    return parsed.data!;
  }

  Future<List<ChefModel>> getChefs({
    required double lat,
    required double lng,
    String? search,
  }) async {
    final res = await _client.dio.get('/user/chefs', queryParameters: {
      'lat': lat,
      'long': lng,
      'radius': 30,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return _parsePaginated(res.data, ChefModel.fromJson);
  }

  Future<Map<String, dynamic>> getChef(int id) async {
    final res = await _client.dio.get('/user/chef', queryParameters: {'id': id});
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status || parsed.data == null) {
      throw ApiException(parsed.errorMsg ?? 'Chef not found');
    }
    return parsed.data as Map<String, dynamic>;
  }

  List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final parsed = ApiResponse.fromJson(raw as Map<String, dynamic>);
    if (!parsed.status) throw ApiException(parsed.errorMsg ?? 'Failed');
    final data = parsed.data;
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  List<T> _parsePaginated<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! Map<String, dynamic>) return [];
    if (raw['status'] != true) {
      throw ApiException(raw['error_msg']?.toString() ?? 'Failed');
    }
    final data = raw['data'];
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
