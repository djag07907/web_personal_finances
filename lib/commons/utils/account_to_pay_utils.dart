import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';

class AccountToPayUtils {
  static bool isOverdue(final AccountToPayItem item, {final DateTime? now}) {
    if (item.isPaid || !item.status) {
      return false;
    }
    final DateTime reference = now ?? DateTime.now();
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final DateTime due = DateTime(
      item.dueDate.year,
      item.dueDate.month,
      item.dueDate.day,
    );
    return due.isBefore(today);
  }
}
