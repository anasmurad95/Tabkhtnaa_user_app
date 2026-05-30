import 'package:provider/provider.dart';

import 'package:provider/single_child_widget.dart';



import '../../features/addresses/data/addresses_repository.dart';

import '../../features/auth/data/auth_repository.dart';

import '../../features/auth/data/bank_info_repository.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/cart/data/cart_repository.dart';

import '../../features/cart/presentation/providers/cart_provider.dart';

import '../../features/catalog/data/catalog_repository.dart';

import '../../features/catalog/presentation/providers/home_provider.dart';

import '../../features/notifications/data/notifications_repository.dart';

import '../../features/notifications/presentation/providers/notifications_provider.dart';

import '../../features/orders/data/orders_repository.dart';

import '../../features/orders/presentation/providers/orders_provider.dart';

import '../../features/support/data/support_repository.dart';

import '../../features/support/presentation/providers/support_provider.dart';

import '../../features/localization/data/localization_repository.dart';

import '../../features/localization/presentation/providers/translation_provider.dart';

import '../../features/profile/data/profile_repository.dart';

import '../../features/profile/presentation/providers/profile_provider.dart';

import '../../features/settings/presentation/providers/theme_provider.dart';

import '../../features/chat/data/chat_repository.dart';

import '../../features/chat/presentation/providers/chat_provider.dart';

import '../network/api_client.dart';

import '../services/location_service.dart';

import '../storage/token_storage.dart';



List<SingleChildWidget> buildProviders() {

  final tokenStorage = TokenStorage();

  final apiClient = ApiClient(tokenStorage);

  final locationService = LocationService();



  final localizationRepo = LocalizationRepository(apiClient);

  final authRepo = AuthRepository(apiClient, tokenStorage);

  final bankInfoRepo = BankInfoRepository(apiClient);

  final catalogRepo = CatalogRepository(apiClient);

  final cartRepo = CartRepository(apiClient);

  final ordersRepo = OrdersRepository(apiClient);

  final addressesRepo = AddressesRepository(apiClient);

  final notificationsRepo = NotificationsRepository(apiClient);

  final supportRepo = SupportRepository(apiClient);



  final profileRepo = ProfileRepository(apiClient, tokenStorage);



  final chatRepo = ChatRepository(apiClient);



  return [

    Provider.value(value: apiClient),

    Provider.value(value: locationService),

    Provider.value(value: addressesRepo),

    Provider.value(value: bankInfoRepo),

    Provider.value(value: ordersRepo),

    ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),

    ChangeNotifierProvider(

      create: (_) => TranslationProvider(localizationRepo, apiClient)..bootstrap(),

    ),

    ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)..bootstrap()),

    ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(

      create: (ctx) => ProfileProvider(profileRepo, ctx.read<AuthProvider>()),

      update: (_, auth, profile) => profile ?? ProfileProvider(profileRepo, auth),

    ),

    ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(

      create: (_) => HomeProvider(catalogRepo, locationService),

      update: (_, auth, home) => home ?? HomeProvider(catalogRepo, locationService),

    ),

    ChangeNotifierProvider(create: (_) => CartProvider(cartRepo)),

    ChangeNotifierProvider(create: (_) => OrdersProvider(ordersRepo)),

    ChangeNotifierProvider(create: (_) => NotificationsProvider(notificationsRepo)),

    ChangeNotifierProvider(create: (_) => SupportProvider(supportRepo)),

    ChangeNotifierProvider(create: (_) => ChatProvider(chatRepo)),

  ];

}


