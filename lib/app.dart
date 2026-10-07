import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mini_ecommerce_app_prompt/core/di/injection.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SessionBloc>()),
        BlocProvider.value(value: getIt<CartBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Mini shop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
