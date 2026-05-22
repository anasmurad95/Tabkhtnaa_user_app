import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/addresses/data/addresses_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/data/cart_repository.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/catalog/presentation/providers/home_provider.dart';
import '../../features/orders/data/orders_repository.dart';
import '../../features/orders/presentation/providers/orders_provider.dart';
import '../../features/localization/data/localization_repository.dart';
import '../../features/localization/presentation/providers/translation_provider.dart';
import '../../features/settings/presentation/providers/theme_provider.dart';
import '../network/api_client.dart';
import '../services/location_service.dart';
import '../storage/token_storage.dart';

List<SingleChildWidget> buildProviders() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);
  final locationService = LocationService();

  final localizationRepo = LocalizationRepository(apiClient);
  final authRepo = AuthRepository(apiClient, tokenStorage);
  final catalogRepo = CatalogRepository(apiClient);
  final cartRepo = CartRepository(apiClient);
  final ordersRepo = OrdersRepository(apiClient);
  final addressesRepo = AddressesRepository(apiClient);

  return [
    Provider.value(value: apiClient),
    Provider.value(value: locationService),
    Provider.value(value: addressesRepo),
    ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
    ChangeNotifierProvider(
      create: (_) => TranslationProvider(localizationRepo, apiClient)..bootstrap(),
    ),
    ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)..bootstrap()),
    ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
      create: (_) => HomeProvider(catalogRepo, locationService),
      update: (_, auth, home) => home ?? HomeProvider(catalogRepo, locationService),
    ),
    ChangeNotifierProvider(create: (_) => CartProvider(cartRepo)),
    ChangeNotifierProvider(create: (_) => OrdersProvider(ordersRepo)),
  ];
}
