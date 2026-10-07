import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/loading_view.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingView());
  }
}
