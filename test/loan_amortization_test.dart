import 'package:flutter_test/flutter_test.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/enum/custom_interest_type.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';

void main() {
  group('LoanAmortizationUtils & CustomInterestType Tests', () {
    test('Flat Rate: 5,000 at 20% APR over 12 monthly quotas', () {
      final double quota = LoanAmortizationUtils.calculatePeriodicQuota(
        principal: 5000.0,
        annualInterestRatePercent: 20.0,
        totalQuotas: 12,
        frequency: CustomFrequencyOptions.monthly,
        interestType: CustomInterestType.flat,
      );

      // (5000 + (5000 * 0.20 * 1.0)) / 12 = (5000 + 1000) / 12 = 500.0
      expect(quota, closeTo(500.0, 0.01));

      final List<AmortizationScheduleItem> schedule =
          LoanAmortizationUtils.generateScheduleForTerms(
        principal: 5000.0,
        annualRate: 20.0,
        totalQuotas: 12,
        frequency: CustomFrequencyOptions.monthly,
        totalPaid: 0.0,
        isFullyPaid: false,
        startDate: DateTime(2026, 1, 1),
        interestType: CustomInterestType.flat,
      );

      expect(schedule.length, 12);
      expect(schedule.first.quotaAmount, closeTo(500.0, 0.01));
      expect(schedule.first.interest, closeTo(83.33, 0.05));
      expect(schedule.first.principal, closeTo(416.67, 0.05));

      final double totalInterest =
          LoanAmortizationUtils.calculateTotalInterest(schedule);
      expect(totalInterest, closeTo(1000.0, 0.05));

      final double totalPrincipal = schedule.fold(
        0.0,
        (final double sum, final AmortizationScheduleItem item) =>
            sum + item.principal,
      );
      expect(totalPrincipal, closeTo(5000.0, 0.05));
    });

    test('French Amortization: 5,000 at 20% APR over 12 monthly quotas', () {
      final double quota = LoanAmortizationUtils.calculatePeriodicQuota(
        principal: 5000.0,
        annualInterestRatePercent: 20.0,
        totalQuotas: 12,
        frequency: CustomFrequencyOptions.monthly,
        interestType: CustomInterestType.french,
      );

      // French quota ~ 463.17
      expect(quota, closeTo(463.17, 0.05));

      final List<AmortizationScheduleItem> schedule =
          LoanAmortizationUtils.generateScheduleForTerms(
        principal: 5000.0,
        annualRate: 20.0,
        totalQuotas: 12,
        frequency: CustomFrequencyOptions.monthly,
        totalPaid: 0.0,
        isFullyPaid: false,
        startDate: DateTime(2026, 1, 1),
        interestType: CustomInterestType.french,
      );

      expect(schedule.length, 12);
      final double totalInterest =
          LoanAmortizationUtils.calculateTotalInterest(schedule);
      expect(totalInterest, closeTo(558.07, 0.5));
    });

    test('AccountReceivableItem model calculates totals correctly with flat rate', () {
      final AccountReceivableItem item = AccountReceivableItem(
        id: '1',
        debtorName: 'Juan Perez',
        description: 'Personal Loan',
        amount: 5000.0,
        currency: 'HNL',
        dueDate: DateTime.now(),
        isLoan: true,
        interestRate: 20.0,
        totalQuotas: 12,
        frequency: CustomFrequencyOptions.monthly,
        interestType: CustomInterestType.flat,
      );

      expect(item.totalLoanInterest, closeTo(1000.0, 0.05));
      expect(item.totalReceivableAmount, closeTo(6000.0, 0.05));
      expect(item.remainingBalance, closeTo(6000.0, 0.05));
    });

    test('AccountToPayItem model calculates totals correctly with french and flat', () {
      final AccountToPayItem frenchItem = AccountToPayItem(
        id: '1',
        creditorName: 'Bank',
        description: 'Loan',
        amount: 5000.0,
        currency: 'HNL',
        dueDate: DateTime.now(),
        isLoan: true,
        interestRate: 20.0,
        totalQuotas: 12,
        frequency: CustomFrequencyOptions.monthly,
        interestType: CustomInterestType.french,
      );

      expect(frenchItem.totalLoanInterest, closeTo(558.07, 0.5));
      expect(frenchItem.totalObligation, closeTo(5558.07, 0.5));

      final AccountToPayItem flatItem = frenchItem.copyWith(
        interestType: CustomInterestType.flat,
      );

      expect(flatItem.totalLoanInterest, closeTo(1000.0, 0.05));
      expect(flatItem.totalObligation, closeTo(6000.0, 0.05));
    });
  });
}
