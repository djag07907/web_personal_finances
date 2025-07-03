class SavingRegistryItem {
  final String id;
  final String savingId;
  final double amount;
  final String type; // "deposit" or "withdraw"
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

  factory SavingRegistryItem.fromMap(final Map<String, dynamic> map) {
    return SavingRegistryItem(
      id: map['id'],
      savingId: map['savingId'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      date: DateTime.parse(map['date']),
      createdDate: DateTime.parse(map['createdDate']),
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'savingId': savingId,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'comment': comment,
    };
  }
}
