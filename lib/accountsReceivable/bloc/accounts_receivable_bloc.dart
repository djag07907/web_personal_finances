import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/repository/accounts_receivable_repository.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/resources/constants.dart';

part 'accounts_receivable_event.dart';
part 'accounts_receivable_state.dart';

class AccountsReceivableBloc extends Bloc<AccountsReceivableEvent, BaseState> {
  final AccountReceivableRepository accountReceivableRepository;

  AccountsReceivableBloc({required this.accountReceivableRepository})
    : super(AccountsReceivableInitial()) {
    on<AccountsReceivableAdded>(_onAdded);
    on<AccountsReceivableUpdated>(_onUpdated);
    on<AccountsReceivableDeleted>(_onDeleted);
    on<AccountsReceivableFetched>(_onFetched);
  }

  String _resolveUserId(final String userId) {
    return userId.isNotEmpty
        ? userId
        : FirebaseAuth.instance.currentUser?.uid ?? emptyString;
  }

  Future<void> _onAdded(
    final AccountsReceivableAdded event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsReceivableInProgress());
    try {
      await accountReceivableRepository.addAccountReceivable(event.item);
      final List<AccountReceivableItem> items =
          await accountReceivableRepository
              .getAccountsReceivable(_resolveUserId(event.item.userId))
              .first;
      emit(AccountsReceivableSuccess(items: items));
    } catch (error) {
      emit(AccountsReceivableError(error: error.toString()));
    }
  }

  Future<void> _onUpdated(
    final AccountsReceivableUpdated event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsReceivableInProgress());
    try {
      await accountReceivableRepository.updateAccountReceivable(event.item);
      final List<AccountReceivableItem> items =
          await accountReceivableRepository
              .getAccountsReceivable(_resolveUserId(event.item.userId))
              .first;
      emit(AccountsReceivableSuccess(items: items));
    } catch (error) {
      emit(AccountsReceivableError(error: error.toString()));
    }
  }

  Future<void> _onDeleted(
    final AccountsReceivableDeleted event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsReceivableInProgress());
    try {
      await accountReceivableRepository.deleteAccountReceivable(event.id);
      final List<AccountReceivableItem> items =
          await accountReceivableRepository
              .getAccountsReceivable(_resolveUserId(event.userId))
              .first;
      emit(AccountsReceivableSuccess(items: items));
    } catch (error) {
      emit(AccountsReceivableError(error: error.toString()));
    }
  }

  Future<void> _onFetched(
    final AccountsReceivableFetched event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsReceivableInProgress());
    try {
      final List<AccountReceivableItem> items =
          await accountReceivableRepository
              .getAccountsReceivable(_resolveUserId(event.userId))
              .first;
      emit(AccountsReceivableSuccess(items: items));
    } catch (error) {
      emit(AccountsReceivableError(error: error.toString()));
    }
  }
}
