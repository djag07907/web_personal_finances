import 'package:web_personal_finances/savings/model/saving_item.dart';

class SavingUtils {
  /// Sums total liquid saved across active goals matching [currency].
  static double calculateTotalSaved(
    final List<SavingItem> items,
    final String currency,
  ) {
    return items
        .where((final SavingItem i) => i.status && i.currency == currency)
        .fold(
          0.0,
          (final double sum, final SavingItem i) => sum + i.currentAmount,
        );
  }

  /// Sums total target goals across active goals matching [currency].
  static double calculateTotalGoal(
    final List<SavingItem> items,
    final String currency,
  ) {
    return items
        .where((final SavingItem i) => i.status && i.currency == currency)
        .fold(
          0.0,
          (final double sum, final SavingItem i) => sum + i.goalAmount,
        );
  }

  /// Calculates overall completion percentage towards aggregate active goals matching [currency].
  static double calculateOverallProgress(
    final List<SavingItem> items,
    final String currency,
  ) {
    final double totalSaved = calculateTotalSaved(items, currency);
    final double totalGoal = calculateTotalGoal(items, currency);
    if (totalGoal <= 0) {
      return 0.0;
    }
    return (totalSaved / totalGoal * 100.0).clamp(0.0, 100.0);
  }

  /// Calculates total monthly savings needed across all dated, incomplete active goals matching [currency].
  static double calculateTotalMonthlyContribution(
    final List<SavingItem> items,
    final String currency,
  ) {
    return items
        .where(
          (final SavingItem i) =>
              i.status && i.currency == currency && !i.isCompleted,
        )
        .fold(
          0.0,
          (final double sum, final SavingItem i) =>
              sum + i.requiredMonthlyContribution,
        );
  }

  /// Returns number of months remaining until [targetDate].
  static int getRemainingMonths(final DateTime targetDate) {
    final DateTime now = DateTime.now();
    if (targetDate.isBefore(now)) {
      return 0;
    }
    int months =
        ((targetDate.year - now.year) * 12) + (targetDate.month - now.month);
    if (targetDate.day < now.day && months > 0) {
      months -= 1;
    }
    return months < 0 ? 0 : months;
  }
}
