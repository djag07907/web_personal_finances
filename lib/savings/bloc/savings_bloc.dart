import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';
import 'package:web_personal_finances/savings/repository/savings_repository.dart';

part 'savings_event.dart';
part 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, BaseState> {
  final SavingsRepository savingsRepository;

  SavingsBloc({required this.savingsRepository}) : super(SavingsInitial()) {
    on<SavingsFetched>(_onFetched);
    on<SavingAdded>(_onAdded);
    on<SavingUpdated>(_onUpdated);
    on<SavingDeleted>(_onDeleted);
    on<SavingTransactionRecorded>(_onTransactionRecorded);
  }

  String _resolveUserId(final String userId) {
    return userId.isNotEmpty
        ? userId
        : FirebaseAuth.instance.currentUser?.uid ?? emptyString;
  }

  Future<void> _onFetched(
    final SavingsFetched event,
    final Emitter<BaseState> emit,
  ) async {
    emit(SavingsInProgress());
    try {
      final List<SavingItem> items = await savingsRepository
          .getSavings(_resolveUserId(event.userId))
          .first;
      emit(SavingsSuccess(items: items));
    } catch (error) {
      emit(SavingsError(error: error.toString()));
    }
  }

  Future<void> _onAdded(
    final SavingAdded event,
    final Emitter<BaseState> emit,
  ) async {
    emit(SavingsInProgress());
    try {
      await savingsRepository.addSaving(event.item);
      final List<SavingItem> items = await savingsRepository
          .getSavings(_resolveUserId(event.item.userId))
          .first;
      emit(SavingsSuccess(items: items));
    } catch (error) {
      emit(SavingsError(error: error.toString()));
    }
  }

  Future<void> _onUpdated(
    final SavingUpdated event,
    final Emitter<BaseState> emit,
  ) async {
    emit(SavingsInProgress());
    try {
      await savingsRepository.updateSaving(event.item);
      final List<SavingItem> items = await savingsRepository
          .getSavings(_resolveUserId(event.item.userId))
          .first;
      emit(SavingsSuccess(items: items));
    } catch (error) {
      emit(SavingsError(error: error.toString()));
    }
  }

  Future<void> _onDeleted(
    final SavingDeleted event,
    final Emitter<BaseState> emit,
  ) async {
    emit(SavingsInProgress());
    try {
      await savingsRepository.deleteSaving(event.id);
      final List<SavingItem> items = await savingsRepository
          .getSavings(_resolveUserId(event.userId))
          .first;
      emit(SavingsSuccess(items: items));
    } catch (error) {
      emit(SavingsError(error: error.toString()));
    }
  }

  Future<void> _onTransactionRecorded(
    final SavingTransactionRecorded event,
    final Emitter<BaseState> emit,
  ) async {
    emit(SavingsInProgress());
    try {
      await savingsRepository.recordTransaction(
        savingId: event.savingId,
        transaction: event.transaction,
      );
      final List<SavingItem> items = await savingsRepository
          .getSavings(_resolveUserId(event.userId))
          .first;
      emit(SavingsSuccess(items: items));
    } catch (error) {
      emit(SavingsError(error: error.toString()));
    }
  }
}
