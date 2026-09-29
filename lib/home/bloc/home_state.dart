import 'package:equatable/equatable.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserModel profile;

  const HomeLoaded({required this.profile});

  @override
  List<Object?> get props => <Object?>[profile];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}
