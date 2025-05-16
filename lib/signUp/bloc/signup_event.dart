import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class SignUpSubmitted extends SignupEvent {
  final String email;
  final String password;

  const SignUpSubmitted({
    required this.email,
    required this.password,
  });
}
