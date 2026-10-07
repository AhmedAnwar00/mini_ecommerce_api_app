import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/presentation/view/login_page.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/view/cart_page.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/data/order.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/view/checkout_page.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/view/order_confirmation_page.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/presentation/viewmodel/checkout_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/product_details/presentation/view/product_details_page.dart';
import 'package:mini_ecommerce_app_prompt/features/products/presentation/view/products_page.dart';
import 'package:mini_ecommerce_app_prompt/features/product_details/presentation/viewmodel/product_details_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/products/presentation/viewmodel/products_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/presentation/view/profile_page.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/presentation/viewmodel/profile_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/splash/presentation/view/splash_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildRouter(GetIt locator) {
  final session = locator<SessionCubit>();
  SessionState? previous;
  var pendingProductsRedirect = false;
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(session.stream),
    redirect: (context, state) {
      final sessionState = session.state;
      final location = state.matchedLocation;
      if (sessionState is SessionAuthenticated) {
        pendingProductsRedirect = false;
      } else if (sessionState is SessionUnauthenticated &&
          sessionState.signedOut &&
          previous is! SessionUnauthenticated) {
        pendingProductsRedirect = true;
      }
      previous = sessionState;
      if (sessionState is SessionLoading) {
        return location == '/' ? null : '/';
      }
      if (pendingProductsRedirect) {
        if (location != '/products') return '/products';
        pendingProductsRedirect = false;
        return null;
      }
      final authed = sessionState is SessionAuthenticated;
      if (location == '/') return '/products';
      if (!authed && _isProtected(location)) {
        return '/login?from=${Uri.encodeComponent(location)}';
      }
      if (authed && location == '/login') {
        return _safeReturnPath(state.uri.queryParameters['from']) ??
            '/products';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => locator<LoginCubit>(),
            child: const LoginPage(),
          );
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                locator<ProductsCubit>()..loadProducts(),
            child: const ProductsPage(),
          );
        },
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BlocProvider(
            create: (_) =>
                locator<ProductDetailsCubit>(param1: id, param2: '')
                  ..loadProduct(),
            child: const ProductDetailsPage(),
          );
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                locator<CheckoutCubit>()..load(),
            child: const CheckoutPage(),
          );
        },
      ),
      GoRoute(
        path: '/checkout/confirmation',
        builder: (context, state) {
          final extra = state.extra;
          return OrderConfirmationPage(
            placedOrder: extra is PlacedOrder ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                locator<ProfileCubit>()..loadProfile(),
            child: const ProfilePage(),
          );
        },
      ),
    ],
  );
}

bool _isProtected(String location) {
  return location == '/checkout' ||
      location == '/checkout/confirmation' ||
      location == '/profile';
}

String? _safeReturnPath(String? from) {
  if (from == null || !from.startsWith('/') || from.startsWith('//')) {
    return null;
  }
  if (from.startsWith('/login')) return null;
  return from;
}
