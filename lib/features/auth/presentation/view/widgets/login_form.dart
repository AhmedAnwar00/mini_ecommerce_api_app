import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/data/login_request.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_event.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/presentation/viewmodel/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.state});

  final LoginState state;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final submitting = widget.state is LoginSubmitting;
    final message = switch (widget.state) {
      LoginFailure(:final message) => message,
      _ => null,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          enabled: !submitting,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (value) => setState(() => _email = value),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: !submitting,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(labelText: 'Password'),
          onChanged: (value) => setState(() => _password = value),
          onSubmitted: (_) => _submit(),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: submitting ? null : _submit,
          child: submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Log in'),
        ),
      ],
    );
  }

  void _submit() {
    context.read<LoginBloc>().add(
      LoginSubmitted(LoginRequest(email: _email, password: _password)),
    );
  }
}
