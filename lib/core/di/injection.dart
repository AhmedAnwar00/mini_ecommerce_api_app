import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mini_ecommerce_app_prompt/core/network/auth_interceptor.dart';
import 'package:mini_ecommerce_app_prompt/core/network/dio_client.dart';
import 'package:mini_ecommerce_app_prompt/core/network/unauthorized_notifier.dart';
import 'package:mini_ecommerce_app_prompt/core/router/app_router.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/key_value_store.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/preferences_key_value_store.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/secure_token_storage.dart';
import 'package:mini_ecommerce_app_prompt/core/storage/token_storage.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/auth_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/dio_auth_api.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/data/cart_repository.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/checkout_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/coupon_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/dio_checkout_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/dio_coupon_api.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/calculate_checkout.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/domain/checkout_policy.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/viewmodel/checkout_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/dio_products_api.dart';
import 'package:mini_ecommerce_app_prompt/features/products/data/products_api.dart';
import 'package:mini_ecommerce_app_prompt/features/product_details/presentation/viewmodel/product_details_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/products/presentation/viewmodel/products_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/dio_profile_api.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/presentation/viewmodel/profile_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  final tokenStorage = SecureTokenStorage(const FlutterSecureStorage());
  final unauthorizedNotifier = UnauthorizedNotifier();
  final dio = createDio(
    baseUrl: apiBaseUrl,
    authInterceptor: AuthInterceptor(tokenStorage, unauthorizedNotifier),
  );
  getIt
    ..registerSingleton<KeyValueStore>(PreferencesKeyValueStore(preferences))
    ..registerSingleton<TokenStorage>(tokenStorage)
    ..registerSingleton<UnauthorizedNotifier>(unauthorizedNotifier)
    ..registerSingleton<AuthApi>(DioAuthApi(dio))
    ..registerSingleton<ProductsApi>(DioProductsApi(dio))
    ..registerSingleton<CouponApi>(DioCouponApi(dio))
    ..registerSingleton<CheckoutApi>(DioCheckoutApi(dio))
    ..registerSingleton<ProfileApi>(DioProfileApi(dio))
    ..registerSingleton(AuthRepository(getIt(), getIt()))
    ..registerSingleton(CartRepository(getIt()))
    ..registerLazySingleton(CalculateCheckout.new)
    ..registerLazySingleton(() => CheckoutPolicy.standard)
    ..registerLazySingleton(
      () => SessionBloc(
        authRepository: getIt(),
        profileApi: getIt(),
        unauthorizedNotifier: getIt(),
      ),
    )
    ..registerLazySingleton(
      () => CartCubit(repository: getIt(), sessionBloc: getIt()),
    )
    ..registerLazySingleton<GoRouter>(() => buildRouter(getIt))
    ..registerFactory(() => LoginCubit(getIt()))
    ..registerFactory(() => ProductsCubit(getIt()))
    ..registerFactoryParam<ProductDetailsBloc, String, String>(
      (productId, _) => ProductDetailsBloc(getIt<ProductsApi>(), productId),
    )
    ..registerFactory(() {
      final session = getIt<SessionBloc>().state;
      final user = session is SessionAuthenticated ? session.user : null;
      return CheckoutBloc(
        cartRepository: getIt(),
        couponApi: getIt(),
        checkoutApi: getIt(),
        calculateCheckout: getIt(),
        policy: getIt(),
        ownerId: user?.id,
        membershipBasisPoints: user?.membershipBasisPoints ?? 0,
      );
    })
    ..registerFactory(() => ProfileCubit(getIt()));
}
