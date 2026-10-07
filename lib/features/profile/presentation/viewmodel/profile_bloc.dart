import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mini_ecommerce_app_prompt/core/error/app_failure.dart';
import 'package:mini_ecommerce_app_prompt/features/auth/data/user.dart';
import 'package:mini_ecommerce_app_prompt/features/profile/data/profile_api.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

sealed class ProfileState {
  const ProfileState();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;
}

class ProfileReady extends ProfileState {
  const ProfileReady(this.user);

  final User user;
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._api) : super(const ProfileLoading()) {
    on<ProfileRequested>(_onRequested);
  }

  final ProfileApi _api;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _api.me();
      emit(ProfileReady(user));
    } on AppFailure catch (failure) {
      emit(ProfileFailure(failure.message));
    }
  }
}
