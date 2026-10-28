import 'dart:math' as math;
import 'package:web_personal_finances/commons/enum/custom_saving_category_options.dart';
import 'package:web_personal_finances/commons/enum/custom_saving_transaction_type.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';

class SavingItem {
  final String id;
  final String userId;
  final String name;
  final String comment;
  final String currency;
  final double amount; // Initial starting amount
  final double goalAmount;
  final DateTime? targetDate;
  final CustomSavingCategoryOptions category;
  final bool isGoalReached;
  final bool status;
  final DateTime? createdDate;
  final List<String> tags;
  final List<SavingRegistryItem> registries;

  SavingItem({
    required this.id,
    this.userId = emptyString,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.goalAmount,
    this.targetDate,
    this.category = CustomSavingCategoryOptions.other,
    this.isGoalReached = false,
    this.status = true,
    this.createdDate,
    this.tags = const <String>[],
    this.registries = const <SavingRegistryItem>[],
  });

  /// Total current saved amount calculated from initial amount + net movement ledger.
  double get currentAmount {
    if (registries.isEmpty) {
      return math.max(0.0, amount);
    }
    final double netMovements = registries.fold(0.0, (
      final double sum,
      final SavingRegistryItem r,
    ) {
      return sum +
          (r.type == CustomSavingTransactionType.deposit
              ? r.amount
              : -r.amount);
    });
    final double total = amount + netMovements;
    return total < 0 ? 0.0 : total;
  }

  /// Completion percentage towards the goal (clamped 0 - 100%).
  double get progressPercent {
    if (goalAmount <= 0) {
      return 0.0;
    }
    return (currentAmount / goalAmount * 100.0).clamp(0.0, 100.0);
  }

  /// Amount still needed to achieve the goal.
  double get remainingAmount {
    final double rem = goalAmount - currentAmount;
    return rem < 0 ? 0.0 : rem;
  }

  /// True if the goal is marked reached or current saved meets/exceeds the goal.
  bool get isCompleted =>
      isGoalReached || (goalAmount > 0 && currentAmount >= goalAmount);

  /// Estimated monthly contribution needed to meet the goal on time.
  double get requiredMonthlyContribution {
    if (isCompleted || remainingAmount <= 0 || targetDate == null) {
      return 0.0;
    }
    final DateTime now = DateTime.now();
    if (targetDate!.isBefore(now)) {
      return remainingAmount;
    }
    int months =
        ((targetDate!.year - now.year) * 12) + (targetDate!.month - now.month);
    if (targetDate!.day < now.day && months > 0) {
      months -= 1;
    }
    if (months <= 0) {
      return remainingAmount;
    }
    return remainingAmount / months;
  }

  SavingItem copyWith({
    final String? id,
    final String? userId,
    final String? name,
    final String? comment,
    final String? currency,
    final double? amount,
    final double? goalAmount,
    final DateTime? targetDate,
    final CustomSavingCategoryOptions? category,
    final bool? isGoalReached,
    final bool? status,
    final DateTime? createdDate,
    final List<String>? tags,
    final List<SavingRegistryItem>? registries,
    final bool clearTargetDate = false,
  }) {
    return SavingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      comment: comment ?? this.comment,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      goalAmount: goalAmount ?? this.goalAmount,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      category: category ?? this.category,
      isGoalReached: isGoalReached ?? this.isGoalReached,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      tags: tags ?? this.tags,
      registries: registries ?? this.registries,
    );
  }

  factory SavingItem.fromMap(final Map<String, dynamic> map) {
    return SavingItem(
      id: map['id'] ?? emptyString,
      userId: map['userId'] ?? emptyString,
      name: map['name'] ?? emptyString,
      comment: map['comment'] ?? emptyString,
      currency: map['currency'] ?? usdCurrency,
      amount: map['amount'] is num
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount']?.toString() ?? emptyString) ?? 0.0,
      goalAmount: map['goalAmount'] is num
          ? (map['goalAmount'] as num).toDouble()
          : double.tryParse(map['goalAmount']?.toString() ?? emptyString) ??
                0.0,
      targetDate: map['targetDate'] != null
          ? DateTime.tryParse(map['targetDate'])
          : null,
      category: CustomSavingCategoryOptions.values.firstWhere(
        (final CustomSavingCategoryOptions e) => e.name == map['category'],
        orElse: () => CustomSavingCategoryOptions.other,
      ),
      isGoalReached: map['isGoalReached'] ?? false,
      status: map['status'] ?? true,
      createdDate: map['createdDate'] != null
          ? DateTime.tryParse(map['createdDate'])
          : DateTime.now(),
      tags: map['tags'] != null
          ? List<String>.from(map['tags'])
          : const <String>[],
      registries: map['registries'] != null
          ? (map['registries'] as List<dynamic>)
                .map(
                  (final dynamic r) => SavingRegistryItem.fromMap(
                    Map<String, dynamic>.from(r as Map<dynamic, dynamic>),
                  ),
                )
                .toList()
          : const <SavingRegistryItem>[],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'name': name,
      'comment': comment,
      'currency': currency,
      'amount': amount,
      'goalAmount': goalAmount,
      'targetDate': targetDate?.toIso8601String(),
      'category': category.name,
      'isGoalReached': isGoalReached,
      'status': status,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'registries': registries
          .map((final SavingRegistryItem r) => r.toMap())
          .toList(),
    };
  }
}
