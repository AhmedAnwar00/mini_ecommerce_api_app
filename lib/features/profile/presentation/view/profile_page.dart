import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/ui/widgets/error_view.dart';
import 'package:mini_ecommerce_app_prompt/core/ui/widgets/loading_view.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/presentation/view/widgets/logout_button.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/presentation/view/widgets/profile_details.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/presentation/viewmodel/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() => const LoadingView(),
            ProfileFailure(:final message) => ErrorView(
              message: message,
              onAction: () {
                context.read<ProfileCubit>().loadProfile();
              },
            ),
            ProfileReady(:final user) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileDetails(user: user),
                  const SizedBox(height: 24),
                  const LogoutButton(),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}
