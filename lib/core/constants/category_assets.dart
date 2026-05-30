/// Local category icon paths under [assets/images/categories/].
///
/// Run `dart tool/copy_category_icons.dart` (or `tool/copy_category_icons.ps1`)
/// after cloning to populate PNGs from the Laravel backend design exports.
abstract final class CategoryAssets {
  static const _dir = 'assets/images/categories/';

  static const _fruitsFile = '$_dirفواكة شهية.png';

  static const defaultIcon = _fruitsFile;

  static const _fileByKey = <String, String>{
    'appetizers': '${_dir}Appetizers-01.png',
    'asian_food': '${_dir}Asian food-01.png',
    'aslan_food': '${_dir}Asian food-01.png',
    'bakery': '${_dir}Bakery-01.png',
    'barbeque': '${_dir}Barbeque-01.png',
    'dessert': '${_dir}Dessert-01.png',
    'drinks': '${_dir}Drinks-01.png',
    'fast_food': '${_dir}Fast food-01.png',
    'frozen': '${_dir}Frozen-01.png',
    'healthy_food': '${_dir}Healthy food-01.png',
    'oriental_food': '${_dir}Oriental food-01.png',
    'pasta': '${_dir}Pasta-01.png',
    'pickels': '${_dir}Pickels-01.png',
    'salad': '${_dir}Salad-01.png',
    'sandwiches': '${_dir}Sandwiches-01.png',
    'soup': '${_dir}Soup-01.png',
    'spicy': '${_dir}Spicy-01.png',
    'western': '${_dir}Western-01.png',
    'orders': _fruitsFile,
    'fruits': _fruitsFile,
  };

  /// Backend public path used when bundled assets or API icon URL are unavailable.
  static const _backendFileByKey = <String, String>{
    'appetizers': 'images/categorise/Appetizers-01.png',
    'asian_food': 'images/categorise/Asian food-01.png',
    'aslan_food': 'images/categorise/Asian food-01.png',
    'bakery': 'images/categorise/Bakery-01.png',
    'barbeque': 'images/categorise/Barbeque-01.png',
    'dessert': 'images/categorise/Dessert-01.png',
    'drinks': 'images/categorise/Drinks-01.png',
    'fast_food': 'images/categorise/Fast food-01.png',
    'frozen': 'images/categorise/Frozen-01.png',
    'healthy_food': 'images/categorise/Healthy food-01.png',
    'orders': 'images/categorise/Orders-01.png',
    'oriental_food': 'images/categorise/Oriental food-01.png',
    'pasta': 'images/categorise/Pasta-01.png',
    'pickels': 'images/categorise/Pickels-01.png',
    'salad': 'images/categorise/Salad-01.png',
    'sandwiches': 'images/categorise/Sandwiches-01.png',
    'soup': 'images/categorise/Soup-01.png',
    'spicy': 'images/categorise/Spicy-01.png',
    'western': 'images/categorise/Western-01.png',
    'fruits': 'images/categorise/فواكة شهية.png',
  };

  /// Arabic labels when API translation and name are missing.
  static const _labelFallbackByKey = <String, String>{
    'appetizers': 'مقبلات',
    'asian_food': 'أطعمة آسيوية',
    'aslan_food': 'أطعمة آسيوية',
    'bakery': 'مخبوزات',
    'barbeque': 'مشاوي',
    'dessert': 'حلويات',
    'drinks': 'مشروبات',
    'fast_food': 'وجبات سريعة',
    'frozen': 'مجمدات',
    'healthy_food': 'أطعمة صحية',
    'oriental_food': 'أطعمة شرقية',
    'pasta': 'معكرونة',
    'pickels': 'مخللات',
    'salad': 'سلطات',
    'sandwiches': 'سندوiches',
    'soup': 'شوربة',
    'spicy': 'أطعمة حارة',
    'western': 'أطعمة غربية',
    'orders': 'فواكة شهية',
    'fruits': 'فواكة شهية',
  };

  /// Normalizes API keys: trim, lowercase, spaces/hyphens → underscores.
  static String normalizeKey(String? key) {
    if (key == null) return '';
    return key
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  static String? assetForKey(String? key) {
    final normalized = normalizeKey(key);
    if (normalized.isEmpty) return null;
    return _fileByKey[normalized];
  }

  static bool hasBundledAssetForKey(String? key) => assetForKey(key) != null;

  static String? backendMediaPathForKey(String? key) {
    final normalized = normalizeKey(key);
    if (normalized.isEmpty) return null;
    return _backendFileByKey[normalized];
  }

  static String? labelFallbackForKey(String? key) {
    final normalized = normalizeKey(key);
    if (normalized.isEmpty) return null;
    return _labelFallbackByKey[normalized];
  }

  static List<String> get knownKeys => _fileByKey.keys.toList(growable: false);

  static List<String> get bundledAssetPaths =>
      _fileByKey.values.toSet().toList(growable: false);
}
