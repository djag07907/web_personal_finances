import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/onboarding/bloc/onboarding_event.dart';
import 'package:web_personal_finances/onboarding/bloc/onboarding_state.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository _userRepository;

  OnboardingBloc({required final UserRepository userRepository})
    : _userRepository = userRepository,
      super(OnboardingInitial()) {
    on<OnboardingSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    final OnboardingSubmitted event,
    final Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingInProgress());
    try {
      final UserModel updatedUser = event.userModel.copyWith(isOnboarded: true);
      await _userRepository.saveUser(updatedUser);
      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingFailure(errorMessage: e.toString()));
    }
  }
}
