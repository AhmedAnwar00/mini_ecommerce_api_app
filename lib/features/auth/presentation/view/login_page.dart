import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/presentation/view/widgets/login_form.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_cubit.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_state.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/session_event.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<SessionBloc>().add(SessionSignedIn(state.user));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Log in')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                return LoginForm(state: state);
              },
            ),
          ),
        ),
      ),
    );
  }
}
