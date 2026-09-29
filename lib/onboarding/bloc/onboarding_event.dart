import 'package:equatable/equatable.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class OnboardingSubmitted extends OnboardingEvent {
  final UserModel userModel;

  const OnboardingSubmitted({required this.userModel});

  @override
  List<Object?> get props => <Object?>[userModel];
}
