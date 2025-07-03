class IncomeItem {
  final String id;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final DateTime dateToReceive;
  final bool status;
  final DateTime? createdDate;
  final List<String> tags;
  final String? paymentMethod;

  IncomeItem({
    required this.id,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.dateToReceive,
    required this.status,
    this.createdDate,
    this.tags = const <String>[],
    this.paymentMethod,
  });

  factory IncomeItem.fromMap(final Map<String, dynamic> map) {
    return IncomeItem(
      id: map['id'],
      name: map['name'],
      comment: map['comment'],
      currency: map['currency'],
      amount: map['amount'].toDouble(),
      dateToReceive: DateTime.parse(map['dateToReceive']),
      status: map['status'] ?? false,
      createdDate: DateTime.parse(map['createdDate']),
      tags: List<String>.from(map['tags'] ?? const <String>[]),
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'comment': comment,
      'currency': currency,
      'amount': amount,
      'dateToReceive': dateToReceive.toIso8601String(),
      'status': status,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'paymentMethod': paymentMethod,
    };
  }
}
