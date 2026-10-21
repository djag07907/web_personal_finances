import 'package:web_personal_finances/commons/enum/custom_saving_transaction_type.dart';
import 'package:web_personal_finances/resources/constants.dart';

class SavingRegistryItem {
  final String id;
  final String savingId;
  final double amount;
  final CustomSavingTransactionType type;
  final DateTime date;
  final String? comment;
  final DateTime createdDate;

  SavingRegistryItem({
    required this.id,
    required this.savingId,
    required this.amount,
    required this.type,
    required this.date,
    required this.createdDate,
    this.comment,
  });

  SavingRegistryItem copyWith({
    final String? id,
    final String? savingId,
    final double? amount,
    final CustomSavingTransactionType? type,
    final DateTime? date,
    final String? comment,
    final DateTime? createdDate,
  }) {
    return SavingRegistryItem(
      id: id ?? this.id,
      savingId: savingId ?? this.savingId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  factory SavingRegistryItem.fromMap(final Map<String, dynamic> map) {
    return SavingRegistryItem(
      id: map['id'] ?? emptyString,
      savingId: map['savingId'] ?? emptyString,
      amount: (map['amount'] ?? 0).toDouble(),
      type: CustomSavingTransactionType.values.firstWhere(
        (final CustomSavingTransactionType e) => e.name == map['type'],
        orElse: () => CustomSavingTransactionType.deposit,
      ),
      date: DateTime.tryParse(map['date'] ?? emptyString) ?? DateTime.now(),
      createdDate:
          DateTime.tryParse(map['createdDate'] ?? emptyString) ??
          DateTime.now(),
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'savingId': savingId,
      'amount': amount,
      'type': type.name,
      'date': date.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'comment': comment,
    };
  }
}
