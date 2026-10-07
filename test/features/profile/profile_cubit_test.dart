import 'package:flutter_test/flutter_test.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/presentation/viewmodel/profile_cubit.dart';

void main() {
  const user = User(
    id: '1',
    name: 'Ada',
    email: 'ada@example.com',
    membershipBasisPoints: 500,
  );

  test('starts in loading', () async {
    final cubit = ProfileCubit(FakeProfileApi(user));

    expect(cubit.state, isA<ProfileLoading>());
    await cubit.close();
  });

  test('emits the current user', () async {
    final cubit = ProfileCubit(FakeProfileApi(user));

    await cubit.loadProfile();

    final state = cubit.state as ProfileReady;
    expect(state.user.id, user.id);
    expect(state.user.name, user.name);
    expect(state.user.email, user.email);
    await cubit.close();
  });

  test('emits a failure message from the api', () async {
    final cubit = ProfileCubit(
      FakeProfileApi(
        user,
        failure: const AppFailure(AppFailureKind.network, 'Offline'),
      ),
    );

    await cubit.loadProfile();

    expect((cubit.state as ProfileFailure).message, 'Offline');
    await cubit.close();
  });
}

class FakeProfileApi implements ProfileApi {
  FakeProfileApi(this.user, {this.failure});

  final User user;
  final AppFailure? failure;

  @override
  Future<User> me() async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return user;
  }
}
