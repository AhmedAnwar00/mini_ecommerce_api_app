import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_event.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.read<SessionBloc>().add(const SessionSignedOut());
      },
      child: const Text('Log out'),
    );
  }
}
