import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => <Object?>[];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingInProgress extends OnboardingState {}

class OnboardingSuccess extends OnboardingState {}

class OnboardingFailure extends OnboardingState {
  final String errorMessage;

  const OnboardingFailure({required this.errorMessage});

  @override
  List<Object?> get props => <Object?>[errorMessage];
}
