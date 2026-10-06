import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_bloc.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/viewmodel/session_state.dart';

class SessionStartupNotice extends StatefulWidget {
  const SessionStartupNotice({super.key, required this.child});

  final Widget child;

  @override
  State<SessionStartupNotice> createState() => _SessionStartupNoticeState();
}

class _SessionStartupNoticeState extends State<SessionStartupNotice> {
  var _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _show());
  }

  void _show() {
    if (_shown || !mounted) return;
    final message = switch (context.read<SessionBloc>().state) {
      SessionUnauthenticated(:final message) => message,
      SessionAuthenticated(:final message) => message,
      _ => null,
    };
    if (message == null) return;
    _shown = true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
