import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeFetchProfile extends HomeEvent {
  const HomeFetchProfile({required this.uid});

  final String uid;

  @override
  List<Object?> get props => <Object?>[uid];
}
