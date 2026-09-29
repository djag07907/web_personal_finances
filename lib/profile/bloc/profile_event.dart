import 'package:equatable/equatable.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ProfileFetchRequested extends ProfileEvent {
  const ProfileFetchRequested({required this.uid});

  final String uid;

  @override
  List<Object?> get props => <Object?>[uid];
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => <Object?>[user];
}
