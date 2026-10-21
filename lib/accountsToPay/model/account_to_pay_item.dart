import 'dart:math' as math;
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_payment.dart';
import 'package:web_personal_finances/commons/enum/custom_account_to_pay_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_frequency_options.dart';
import 'package:web_personal_finances/commons/enum/custom_interest_type.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';
import 'package:web_personal_finances/resources/constants.dart';

class AccountToPayItem {
  final String id;
  final String userId;
  final String creditorName;
  final String description;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final bool isPaid;
  final bool status;
  final CustomAccountToPayCategoryOptions category;
  final CustomFrequencyOptions frequency;
  final DateTime? createdDate;
  final List<String> tags;
  final String? paymentMethod;
  final List<AccountToPayPayment> payments;
  final bool isLoan;
  final double? interestRate;
  final int? totalQuotas;
  final double? monthlyQuota;
  final CustomInterestType interestType;

  AccountToPayItem({
    required this.id,
    this.userId = emptyString,
    required this.creditorName,
    required this.description,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.paymentDate,
    this.isPaid = false,
    this.status = true,
    this.category = CustomAccountToPayCategoryOptions.other,
    this.frequency = CustomFrequencyOptions.once,
    this.createdDate,
    this.tags = const <String>[],
    this.paymentMethod,
    this.payments = const <AccountToPayPayment>[],
    this.isLoan = false,
    this.interestRate,
    this.totalQuotas,
    this.monthlyQuota,
    this.interestType = CustomInterestType.french,
  });

  /// True if this item represents a loan or installment financing.
  bool get isLoanAccount =>
      isLoan ||
      category == CustomAccountToPayCategoryOptions.loan ||
      category == CustomAccountToPayCategoryOptions.mortgage ||
      category == CustomAccountToPayCategoryOptions.installmentDebt ||
      (totalQuotas != null && totalQuotas! > 0);

  /// Total amount paid so far. If payments are recorded in the ledger, sums them.
  /// Otherwise falls back to full amount if marked isPaid.
  double get totalPaid {
    if (payments.isNotEmpty) {
      return payments.fold(
        0.0,
        (final double sum, final AccountToPayPayment p) => sum + p.amount,
      );
    }
    return isPaid ? amount : 0.0;
  }

  /// Total interest to be paid over the life of the loan.
  double get totalLoanInterest {
    if (!isLoanAccount ||
        (totalQuotas == null || totalQuotas! <= 0) ||
        (interestRate == null || interestRate! <= 0)) {
      return 0.0;
    }
    final double quota =
        monthlyQuota ??
        LoanAmortizationUtils.calculatePeriodicQuota(
          principal: amount,
          annualInterestRatePercent: interestRate!,
          totalQuotas: totalQuotas!,
          frequency: frequency,
          interestType: interestType,
        );
    final double total = quota * totalQuotas!;
    return math.max(0.0, total - amount);
  }

  /// Total obligation to be paid (principal + total interest).
  double get totalObligation {
    if (!isLoanAccount || (totalQuotas == null || totalQuotas! <= 0)) {
      return amount;
    }
    if (monthlyQuota != null && monthlyQuota! > 0) {
      return monthlyQuota! * totalQuotas!;
    }
    return amount + totalLoanInterest;
  }

  /// Outstanding balance still owed.
  double get remainingBalance {
    final double total = isLoanAccount ? totalObligation : amount;
    final double rem = total - totalPaid;
    return rem < 0 ? 0.0 : rem;
  }

  /// True when the account has been completely settled.
  bool get isFullyPaid => isPaid || remainingBalance <= 0;

  /// True when at least one payment was made but an outstanding balance remains.
  bool get isPartiallyPaid => !isFullyPaid && totalPaid > 0;

  AccountToPayItem copyWith({
    final String? creditorName,
    final String? description,
    final double? amount,
    final String? currency,
    final DateTime? dueDate,
    final DateTime? paymentDate,
    final bool? isPaid,
    final bool? status,
    final CustomAccountToPayCategoryOptions? category,
    final CustomFrequencyOptions? frequency,
    final List<String>? tags,
    final String? paymentMethod,
    final List<AccountToPayPayment>? payments,
    final bool clearPaymentDate = false,
    final bool? isLoan,
    final double? interestRate,
    final int? totalQuotas,
    final double? monthlyQuota,
    final CustomInterestType? interestType,
  }) {
    return AccountToPayItem(
      id: id,
      userId: userId,
      creditorName: creditorName ?? this.creditorName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: clearPaymentDate ? null : (paymentDate ?? this.paymentDate),
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      createdDate: createdDate,
      tags: tags ?? this.tags,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payments: payments ?? this.payments,
      isLoan: isLoan ?? this.isLoan,
      interestRate: interestRate ?? this.interestRate,
      totalQuotas: totalQuotas ?? this.totalQuotas,
      monthlyQuota: monthlyQuota ?? this.monthlyQuota,
      interestType: interestType ?? this.interestType,
    );
  }

  factory AccountToPayItem.fromMap(final Map<String, dynamic> map) {
    return AccountToPayItem(
      id: map['id'] ?? emptyString,
      userId: map['userId'] ?? emptyString,
      creditorName: map['creditorName'] ?? emptyString,
      description: map['description'] ?? emptyString,
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? usdCurrency,
      dueDate:
          DateTime.tryParse(map['dueDate'] ?? emptyString) ?? DateTime.now(),
      paymentDate: map['paymentDate'] != null
          ? DateTime.tryParse(map['paymentDate'])
          : null,
      isPaid: map['isPaid'] ?? false,
      status: map['status'] ?? true,
      category: CustomAccountToPayCategoryOptions.values.firstWhere(
        (final CustomAccountToPayCategoryOptions element) =>
            element.name == map['category'],
        orElse: () => CustomAccountToPayCategoryOptions.other,
      ),
      frequency: CustomFrequencyOptions.values.firstWhere(
        (final CustomFrequencyOptions element) =>
            element.name == map['frequency'],
        orElse: () => CustomFrequencyOptions.once,
      ),
      createdDate: map['createdDate'] != null
          ? DateTime.tryParse(map['createdDate'])
          : DateTime.now(),
      tags: map['tags'] != null
          ? List<String>.from(map['tags'])
          : const <String>[],
      paymentMethod: map['paymentMethod'],
      payments: map['payments'] != null
          ? (map['payments'] as List<dynamic>)
                .map(
                  (final dynamic p) => AccountToPayPayment.fromMap(
                    Map<String, dynamic>.from(p as Map<dynamic, dynamic>),
                  ),
                )
                .toList()
          : const <AccountToPayPayment>[],
      isLoan: map['isLoan'] ?? false,
      interestRate: map['interestRate'] != null
          ? (map['interestRate'] as num).toDouble()
          : null,
      totalQuotas: map['totalQuotas'] != null
          ? (map['totalQuotas'] as num).toInt()
          : null,
      monthlyQuota: map['monthlyQuota'] != null
          ? (map['monthlyQuota'] as num).toDouble()
          : null,
      interestType: CustomInterestType.values.firstWhere(
        (final CustomInterestType element) =>
            element.name == map['interestType'],
        orElse: () => CustomInterestType.french,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'creditorName': creditorName,
      'description': description,
      'amount': amount,
      'currency': currency,
      'dueDate': dueDate.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'isPaid': isPaid,
      'status': status,
      'category': category.name,
      'frequency': frequency.name,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'paymentMethod': paymentMethod,
      'payments': payments
          .map((final AccountToPayPayment p) => p.toMap())
          .toList(),
      'isLoan': isLoan,
      'interestRate': interestRate,
      'totalQuotas': totalQuotas,
      'monthlyQuota': monthlyQuota,
      'interestType': interestType.name,
    };
  }
}
