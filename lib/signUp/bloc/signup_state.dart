import 'package:equatable/equatable.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignupState {}

class SignUpInProgress extends SignupState {}

class SignUpSuccess extends SignupState {}

class SignUpError extends SignupState {
  final String error;

  const SignUpError({
    required this.error,
  });
}
