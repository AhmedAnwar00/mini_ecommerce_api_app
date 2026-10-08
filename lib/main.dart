import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/app.dart';
import 'package:mini_ecommerce_app_prompt/core/di/injection.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/cart/presentation/viewmodel/cart_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  getIt<SessionCubit>().start();
  getIt<CartCubit>().start();
  runApp(const App());
}
