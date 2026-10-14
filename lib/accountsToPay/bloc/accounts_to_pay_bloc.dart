import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/repository/accounts_to_pay_repository.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/resources/constants.dart';

part 'accounts_to_pay_event.dart';
part 'accounts_to_pay_state.dart';

class AccountsToPayBloc extends Bloc<AccountsToPayEvent, BaseState> {
  final AccountToPayRepository accountToPayRepository;

  AccountsToPayBloc({required this.accountToPayRepository})
    : super(AccountsToPayInitial()) {
    on<AccountsToPayAdded>(_onAdded);
    on<AccountsToPayUpdated>(_onUpdated);
    on<AccountsToPayDeleted>(_onDeleted);
    on<AccountsToPayFetched>(_onFetched);
  }

  String _resolveUserId(final String userId) {
    return userId.isNotEmpty
        ? userId
        : FirebaseAuth.instance.currentUser?.uid ?? emptyString;
  }

  Future<void> _onAdded(
    final AccountsToPayAdded event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsToPayInProgress());
    try {
      await accountToPayRepository.addAccountToPay(event.item);
      final List<AccountToPayItem> items = await accountToPayRepository
          .getAccountsToPay(_resolveUserId(event.item.userId))
          .first;
      emit(AccountsToPaySuccess(items: items));
    } catch (error) {
      emit(AccountsToPayError(error: error.toString()));
    }
  }

  Future<void> _onUpdated(
    final AccountsToPayUpdated event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsToPayInProgress());
    try {
      await accountToPayRepository.updateAccountToPay(event.item);
      final List<AccountToPayItem> items = await accountToPayRepository
          .getAccountsToPay(_resolveUserId(event.item.userId))
          .first;
      emit(AccountsToPaySuccess(items: items));
    } catch (error) {
      emit(AccountsToPayError(error: error.toString()));
    }
  }

  Future<void> _onDeleted(
    final AccountsToPayDeleted event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsToPayInProgress());
    try {
      await accountToPayRepository.deleteAccountToPay(event.id);
      final List<AccountToPayItem> items = await accountToPayRepository
          .getAccountsToPay(_resolveUserId(event.userId))
          .first;
      emit(AccountsToPaySuccess(items: items));
    } catch (error) {
      emit(AccountsToPayError(error: error.toString()));
    }
  }

  Future<void> _onFetched(
    final AccountsToPayFetched event,
    final Emitter<BaseState> emit,
  ) async {
    emit(AccountsToPayInProgress());
    try {
      final List<AccountToPayItem> items = await accountToPayRepository
          .getAccountsToPay(_resolveUserId(event.userId))
          .first;
      emit(AccountsToPaySuccess(items: items));
    } catch (error) {
      emit(AccountsToPayError(error: error.toString()));
    }
  }
}
