import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_personal_finances/commons/bloc/base_state.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/incomes/repository/incomes_repository.dart';

part 'incomes_event.dart';
part 'incomes_state.dart';

class IncomesBloc extends Bloc<IncomesEvent, BaseState> {
  final IncomeRepository incomeRepository;
  IncomesBloc({required this.incomeRepository}) : super(IncomesInitial()) {
    on<IncomesAdded>(_onIncomeAdded);
    on<IncomesUpdated>(_onIncomeUpdated);
    on<IncomesDeleted>(_onIncomeDeleted);
    on<IncomesFetched>(_onIncomeFetched);
  }
  Future<void> _onIncomeAdded(
    final IncomesAdded event,
    final Emitter<BaseState> emit,
  ) async {
    emit(
      IncomesInProgress(),
    );
    try {
      await incomeRepository.addIncome(event.incomeItem);
      final List<IncomeItem> incomes =
          await incomeRepository.getIncomes().first;
      emit(
        IncomesSuccess(
          incomes: incomes,
        ),
      );
    } catch (error) {
      emit(
        IncomesError(
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> _onIncomeUpdated(
    final IncomesUpdated event,
    final Emitter<BaseState> emit,
  ) async {
    emit(
      IncomesInProgress(),
    );
    try {
      await incomeRepository.updateIncome(event.incomeItem);
      final List<IncomeItem> incomes =
          await incomeRepository.getIncomes().first;
      emit(
        IncomesSuccess(
          incomes: incomes,
        ),
      );
    } catch (error) {
      emit(
        IncomesError(
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> _onIncomeDeleted(
    final IncomesDeleted event,
    final Emitter<BaseState> emit,
  ) async {
    emit(
      IncomesInProgress(),
    );
    try {
      await incomeRepository.deleteIncome(event.id);
      final List<IncomeItem> incomes =
          await incomeRepository.getIncomes().first;
      emit(
        IncomesSuccess(
          incomes: incomes,
        ),
      );
    } catch (error) {
      emit(
        IncomesError(
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> _onIncomeFetched(
    final IncomesFetched event,
    final Emitter<BaseState> emit,
  ) async {
    emit(
      IncomesInProgress(),
    );
    try {
      final List<IncomeItem> incomes =
          await incomeRepository.getIncomes().first;
      emit(
        IncomesSuccess(
          incomes: incomes,
        ),
      );
    } catch (error) {
      emit(
        IncomesError(
          error: error.toString(),
        ),
      );
    }
  }
}
