import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/view/login_page.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/login_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_state.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/view/cart_page.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/model/order.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/view/checkout_page.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/view/order_confirmation_page.dart';
import 'package:mini_ecommerce_app_prompt/features/checkout/viewmodel/checkout_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/products/view/product_details_page.dart';
import 'package:mini_ecommerce_app_prompt/features/products/view/products_page.dart';
import 'package:mini_ecommerce_app_prompt/features/products/viewmodel/product_details_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/products/viewmodel/products_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/view/profile_page.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/viewmodel/profile_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/splash/view/splash_page.dart';

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
  final session = locator<SessionBloc>();
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(session.stream),
    redirect: (context, state) {
      final sessionState = session.state;
      final location = state.matchedLocation;
      if (sessionState is SessionLoading) {
        return location == '/' ? null : '/';
      }
      final authed = sessionState is SessionAuthenticated;
      if (!authed && session.shouldOpenProductsAfterLogout) {
        if (location != '/products') return '/products';
        session.clearOpenProductsAfterLogout();
        return null;
      }
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
            create: (_) => locator<LoginBloc>(),
            child: const LoginPage(),
          );
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                locator<ProductsBloc>()..add(const ProductsRequested()),
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
                locator<ProductDetailsBloc>(param1: id, param2: '')
                  ..add(const ProductDetailsRequested()),
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
                locator<CheckoutBloc>()..add(const CheckoutRequested()),
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
                locator<ProfileBloc>()..add(const ProfileRequested()),
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
