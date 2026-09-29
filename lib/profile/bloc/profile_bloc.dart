import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/profile/bloc/profile_event.dart';
import 'package:web_personal_finances/profile/bloc/profile_state.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required this.userRepository}) : super(ProfileInitial()) {
    on<ProfileFetchRequested>(_onFetchRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  final UserRepository userRepository;

  Future<void> _onFetchRequested(
    final ProfileFetchRequested event,
    final Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final UserModel? user = await userRepository.getUser(event.uid);
      if (user != null) {
        emit(ProfileLoaded(user: user));
      } else {
        final User? authUser = FirebaseAuth.instance.currentUser;
        final UserModel fallbackUser = UserModel(
          uid: event.uid,
          email: authUser?.email ?? emptyString,
          fullName: authUser?.displayName ?? emptyString,
        );
        emit(ProfileLoaded(user: fallbackUser));
      }
    } on Exception catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    final ProfileUpdateRequested event,
    final Emitter<ProfileState> emit,
  ) async {
    final UserModel currentUser = event.user;
    emit(ProfileSaving(user: currentUser));
    try {
      await userRepository.saveUser(currentUser);
      emit(
        ProfileSuccess(
          user: currentUser,
          message: 'Profile updated successfully',
        ),
      );
    } on Exception catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
