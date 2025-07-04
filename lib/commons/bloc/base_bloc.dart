import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/resources/constants.dart';

abstract class BaseBloc<T, R> extends Bloc<T, R> {
  BaseBloc(super.initialState);

  Future<void> handleNetworkError(
    final dynamic exception,
    final Emitter<BaseState> emit,
  ) async {
    if (exception.response == null ||
        exception.response.statusCode == null ||
        exception.response.statusMessage == null) {
      return;
    }
    // if (exception.response.statusCode == 401) {
    //   await UserRepository().setUserIsSession('false');
    //   emit(
    //     AuthorizationError(),
    //   );
    // } else
    if (exception.response.statusCode >= 300 &&
        exception.response.statusCode < 500) {
      emit(
        UnknownError(
          '${exception.response?.data[serviceMessage]}',
        ),
      );
    } else if (exception.response.statusCode >= 500) {
      emit(
        ServerClientError(),
      );
    }
  }
}
