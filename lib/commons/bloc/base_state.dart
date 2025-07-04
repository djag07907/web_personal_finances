import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object> get props => [];
}

final class InitialState extends BaseState {}

class ServerClientError extends BaseState {}

class AuthorizationError extends BaseState {}

class UnknownError extends BaseState {
  final String error;

  const UnknownError(
    this.error,
  );
}

class IntegrityFail extends BaseState {}

class InternetFail extends BaseState {}

class ObtainedNewNotificationSuccess extends BaseState {
  final bool isNewNotification;

  ObtainedNewNotificationSuccess({
    required this.isNewNotification,
  });
}
