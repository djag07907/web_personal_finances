import 'package:web_personal_finances/savings/model/saving_registry_item.dart';

class SavingItem {
  final String id;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final double goalAmount;
  final bool isGoalReached;
  final DateTime? createdDate;
  final List<String> tags;

  final List<SavingRegistryItem> registries;

  SavingItem({
    required this.id,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.goalAmount,
    required this.isGoalReached,
    this.createdDate,
    this.tags = const <String>[],
    this.registries = const <SavingRegistryItem>[],
  });

  factory SavingItem.fromMap(final Map<String, dynamic> map) {
    return SavingItem(
      id: map['id'],
      name: map['name'],
      comment: map['comment'],
      currency: map['currency'],
      amount: map['amount'].toDouble(),
      goalAmount: map['goalAmount'].toDouble(),
      isGoalReached: map['isGoalReached'] ?? false,
      createdDate: DateTime.parse(map['createdDate']),
      tags: List<String>.from(map['tags'] ?? <String>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'comment': comment,
      'currency': currency,
      'amount': amount,
      'goalAmount': goalAmount,
      'isGoalReached': isGoalReached,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
    };
  }
}
