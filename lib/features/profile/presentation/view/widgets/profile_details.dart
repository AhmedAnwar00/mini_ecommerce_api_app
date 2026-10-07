import 'package:flutter/material.dart';

import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(user.email),
        const SizedBox(height: 8),
        Text(
          'Membership ${user.membershipBasisPoints ~/ 100}.${(user.membershipBasisPoints % 100).toString().padLeft(2, '0')}%',
        ),
      ],
    );
  }
}
