import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/home/bloc/home_event.dart';
import 'package:web_personal_finances/home/bloc/home_state.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.userRepository}) : super(HomeInitial()) {
    on<HomeFetchProfile>(_onFetchProfile);
  }

  final UserRepository userRepository;

  Future<void> _onFetchProfile(
    final HomeFetchProfile event,
    final Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final UserModel? profile = await userRepository.getUser(event.uid);
      if (profile != null) {
        emit(HomeLoaded(profile: profile));
      } else {
        emit(const HomeError(message: 'Profile not found.'));
      }
    } on Exception catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
