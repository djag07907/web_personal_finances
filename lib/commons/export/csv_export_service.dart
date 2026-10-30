import 'package:intl/intl.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/security/file_download_helper.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';

/// Service responsible for generating RFC 4180 compliant CSV files from
/// decrypted domain models and triggering client-side browser downloads.
class CsvExportService {
  const CsvExportService();

  static final DateFormat _fileDateFmt = DateFormat('yyyy-MM-dd_HHmm');
  static final DateFormat _rowDateFmt = DateFormat('yyyy-MM-dd');

  /// Escapes a CSV cell value according to RFC 4180 standard.
  static String escapeCell(final dynamic value) {
    if (value == null) return '';
    final String str = value.toString();
    if (str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Converts a row of items to a comma-separated line.
  static String toCsvRow(final List<dynamic> cells) {
    return cells.map(escapeCell).join(',');
  }

  /// Generates and triggers download for Incomes CSV.
  void exportIncomes(final List<IncomeItem> items) {
    final StringBuffer csv = StringBuffer();
    csv.writeln(
      toCsvRow(<String>[
        'ID',
        'Title',
        'Amount',
        'Currency',
        'Category',
        'Frequency',
        'Date to Receive',
        'Received',
        'Status',
        'Comment',
        'Tags',
      ]),
    );

    for (final IncomeItem item in items) {
      csv.writeln(
        toCsvRow(<dynamic>[
          item.id,
          item.name,
          item.amount.toStringAsFixed(2),
          item.currency,
          item.category.name,
          item.frequency.name,
          item.dateToReceive,
          item.isReceived ? 'Yes' : 'No',
          item.status ? 'Active' : 'Inactive',
          item.comment,
          item.tags.join('; '),
        ]),
      );
    }

    final String timestamp = _fileDateFmt.format(DateTime.now());
    downloadTextFile(
      filename: 'pecunia_incomes_$timestamp.csv',
      content: csv.toString(),
    );
  }

  /// Generates and triggers download for Expenses CSV.
  void exportExpenses(final List<ExpenseItem> items) {
    final StringBuffer csv = StringBuffer();
    csv.writeln(
      toCsvRow(<String>[
        'ID',
        'Merchant / Description',
        'Amount',
        'Currency',
        'Category',
        'Frequency',
        'Due Date',
        'Paid',
        'Fixed Expense',
        'Payment Method',
        'Status',
        'Comment',
        'Tags',
      ]),
    );

    for (final ExpenseItem item in items) {
      csv.writeln(
        toCsvRow(<dynamic>[
          item.id,
          item.name,
          item.amount.toStringAsFixed(2),
          item.currency,
          item.category.name,
          item.frequency.name,
          item.dateDue,
          item.isPaid ? 'Yes' : 'No',
          item.isFixed ? 'Yes' : 'No',
          item.paymentMethod ?? '',
          item.status ? 'Active' : 'Inactive',
          item.comment,
          item.tags.join('; '),
        ]),
      );
    }

    final String timestamp = _fileDateFmt.format(DateTime.now());
    downloadTextFile(
      filename: 'pecunia_expenses_$timestamp.csv',
      content: csv.toString(),
    );
  }

  /// Generates and triggers download for Accounts to Pay (Debts & Loans) CSV.
  void exportAccountsToPay(final List<AccountToPayItem> items) {
    final StringBuffer csv = StringBuffer();
    csv.writeln(
      toCsvRow(<String>[
        'ID',
        'Creditor Name',
        'Amount / Principal',
        'Currency',
        'Due Date',
        'Category',
        'Is Loan',
        'Interest Rate (%)',
        'Total Quotas',
        'Monthly Quota',
        'Total Paid',
        'Remaining Balance',
        'Fully Paid',
        'Status',
        'Payment Method',
        'Description',
      ]),
    );

    for (final AccountToPayItem item in items) {
      csv.writeln(
        toCsvRow(<dynamic>[
          item.id,
          item.creditorName,
          item.amount.toStringAsFixed(2),
          item.currency,
          _rowDateFmt.format(item.dueDate),
          item.category.name,
          item.isLoan ? 'Yes' : 'No',
          item.interestRate?.toStringAsFixed(2) ?? '',
          item.totalQuotas?.toString() ?? '',
          item.monthlyQuota?.toStringAsFixed(2) ?? '',
          item.totalPaid.toStringAsFixed(2),
          item.remainingBalance.toStringAsFixed(2),
          item.isFullyPaid ? 'Yes' : 'No',
          item.status ? 'Active' : 'Archived',
          item.paymentMethod ?? '',
          item.description,
        ]),
      );
    }

    final String timestamp = _fileDateFmt.format(DateTime.now());
    downloadTextFile(
      filename: 'pecunia_accounts_to_pay_$timestamp.csv',
      content: csv.toString(),
    );
  }

  /// Generates and triggers download for Accounts Receivable CSV.
  void exportAccountsReceivable(final List<AccountReceivableItem> items) {
    final StringBuffer csv = StringBuffer();
    csv.writeln(
      toCsvRow(<String>[
        'ID',
        'Debtor Name',
        'Amount to Collect',
        'Currency',
        'Due Date',
        'Category',
        'Is Loan',
        'Interest Rate (%)',
        'Total Quotas',
        'Monthly Quota',
        'Total Collected',
        'Remaining Balance',
        'Fully Collected',
        'Status',
        'Payment Method',
        'Description',
      ]),
    );

    for (final AccountReceivableItem item in items) {
      csv.writeln(
        toCsvRow(<dynamic>[
          item.id,
          item.debtorName,
          item.amount.toStringAsFixed(2),
          item.currency,
          _rowDateFmt.format(item.dueDate),
          item.category.name,
          item.isLoan ? 'Yes' : 'No',
          item.interestRate?.toStringAsFixed(2) ?? '',
          item.totalQuotas?.toString() ?? '',
          item.monthlyQuota?.toStringAsFixed(2) ?? '',
          item.totalCollected.toStringAsFixed(2),
          item.remainingBalance.toStringAsFixed(2),
          item.isFullyPaid ? 'Yes' : 'No',
          item.status ? 'Active' : 'Archived',
          item.paymentMethod ?? '',
          item.description,
        ]),
      );
    }

    final String timestamp = _fileDateFmt.format(DateTime.now());
    downloadTextFile(
      filename: 'pecunia_accounts_receivable_$timestamp.csv',
      content: csv.toString(),
    );
  }

  /// Generates and triggers download for Savings Goals CSV.
  void exportSavings(final List<SavingItem> items) {
    final StringBuffer csv = StringBuffer();
    csv.writeln(
      toCsvRow(<String>[
        'ID',
        'Goal Title',
        'Current Saved Amount',
        'Target Goal Amount',
        'Progress (%)',
        'Remaining to Goal',
        'Currency',
        'Category',
        'Target Date',
        'Goal Reached',
        'Registries Count',
        'Status',
        'Comment',
      ]),
    );

    for (final SavingItem item in items) {
      csv.writeln(
        toCsvRow(<dynamic>[
          item.id,
          item.name,
          item.currentAmount.toStringAsFixed(2),
          item.goalAmount.toStringAsFixed(2),
          item.progressPercent.toStringAsFixed(1),
          item.remainingAmount.toStringAsFixed(2),
          item.currency,
          item.category.name,
          item.targetDate != null ? _rowDateFmt.format(item.targetDate!) : '',
          item.isCompleted ? 'Yes' : 'No',
          item.registries.length.toString(),
          item.status ? 'Active' : 'Archived',
          item.comment,
        ]),
      );
    }

    final String timestamp = _fileDateFmt.format(DateTime.now());
    downloadTextFile(
      filename: 'pecunia_savings_$timestamp.csv',
      content: csv.toString(),
    );
  }
}
