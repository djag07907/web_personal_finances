import 'package:equatable/equatable.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => <Object?>[user];
}

class ProfileSaving extends ProfileState {
  const ProfileSaving({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => <Object?>[user];
}

class ProfileSuccess extends ProfileState {
  const ProfileSuccess({required this.user, required this.message});

  final UserModel user;
  final String message;

  @override
  List<Object?> get props => <Object?>[user, message];
}

class ProfileError extends ProfileState {
  const ProfileError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
