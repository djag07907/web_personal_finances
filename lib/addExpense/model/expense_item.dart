class ExpenseItem {
  final String id;
  final String name;
  final String comment;
  final String currency;
  final double amount;
  final DateTime dateDue;
  final bool status;
  final DateTime? createdDate;
  final List<String> tags;
  final String? paymentMethod;

  ExpenseItem({
    required this.id,
    required this.name,
    required this.comment,
    required this.currency,
    required this.amount,
    required this.dateDue,
    required this.status,
    this.createdDate,
    this.tags = const <String>[],
    this.paymentMethod,
  });

  factory ExpenseItem.fromMap(final Map<String, dynamic> map) {
    return ExpenseItem(
      id: map['id'],
      name: map['name'],
      comment: map['comment'],
      currency: map['currency'],
      amount: map['amount'].toDouble(),
      dateDue: DateTime.parse(map['dateDue']),
      status: map['status'] ?? false,
      createdDate: DateTime.parse(map['createdDate']),
      tags: List<String>.from(map['tags'] ?? const <String>[]),
      paymentMethod: map['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'comment': comment,
      'currency': currency,
      'amount': amount,
      'dateDue': dateDue.toIso8601String(),
      'status': status,
      'createdDate': createdDate?.toIso8601String(),
      'tags': tags,
      'paymentMethod': paymentMethod,
    };
  }
}
