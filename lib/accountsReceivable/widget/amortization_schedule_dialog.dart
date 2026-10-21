import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/widget/record_payment_dialog.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class AmortizationScheduleDialog extends StatefulWidget {
  final AccountReceivableItem item;
  final void Function(AccountReceivableItem updatedItem) onPaymentRecorded;

  const AmortizationScheduleDialog({
    super.key,
    required this.item,
    required this.onPaymentRecorded,
  });

  static Future<void> show({
    required final BuildContext context,
    required final AccountReceivableItem item,
    required final void Function(AccountReceivableItem) onPaymentRecorded,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (final BuildContext ctx) {
        return Dialog(
          backgroundColor: transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: AmortizationScheduleDialog(
            item: item,
            onPaymentRecorded: onPaymentRecorded,
          ),
        );
      },
    );
  }

  @override
  State<AmortizationScheduleDialog> createState() =>
      _AmortizationScheduleDialogState();
}

class _AmortizationScheduleDialogState
    extends State<AmortizationScheduleDialog> {
  late AccountReceivableItem _currentItem;
  late List<AmortizationScheduleItem> _schedule;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _schedule = LoanAmortizationUtils.generateReceivableSchedule(_currentItem);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onPayNextQuota(final AmortizationScheduleItem nextQuota) {
    RecordPaymentDialog.show(
      context: context,
      item: _currentItem,
      onPaymentRecorded: (final AccountReceivableItem updated) {
        setState(() {
          _currentItem = updated;
          _schedule = LoanAmortizationUtils.generateReceivableSchedule(updated);
        });
        widget.onPaymentRecorded(updated);
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? DarkColors.primary : LightColors.primary;
    final String currency = _currentItem.currency;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxDialogHeight = (screenHeight * 0.90).clamp(420.0, 780.0);
    final double dialogWidth = (screenWidth - 32.0).clamp(340.0, 960.0);

    final double totalInterest = LoanAmortizationUtils.calculateTotalInterest(
      _schedule,
    );
    final double totalCost = _currentItem.amount + totalInterest;
    final int paidQuotas = _schedule
        .where((final AmortizationScheduleItem s) => s.isPaid)
        .length;
    final int totalQuotas = _schedule.length;
    final AmortizationScheduleItem? nextDueQuota =
        LoanAmortizationUtils.getNextDueQuota(_schedule);

    return Container(
      width: dialogWidth,
      constraints: BoxConstraints(maxWidth: 960, maxHeight: maxDialogHeight),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22.0, 18.0, 14.0, 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.table_chart_outlined,
                            size: 20,
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              context.translate('amortization_schedule'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? white : LightColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_currentItem.debtorName} • ${_currentItem.description.isNotEmpty ? _currentItem.description : context.translate('financing_details')} • ${_currentItem.interestType.toTranslate(context)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: context.translate('close'),
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: isDark ? DarkColors.textSecondary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
          ),

          // Loan summary KPIs
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 10.0),
            child: LayoutBuilder(
              builder: (final BuildContext ctx, final BoxConstraints c) {
                final bool isNarrow = c.maxWidth < 640;
                return Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withValues(alpha: 0.2)),
                  ),
                  child: isNarrow
                      ? Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _buildSummaryItem(
                                  label: context.translate('principal'),
                                  value: CurrencyKpiUtils.formatAmount(
                                    _currentItem.amount,
                                    currency,
                                  ),
                                  isDark: isDark,
                                ),
                                _buildSummaryItem(
                                  label: context.translate('interest_rate'),
                                  value:
                                      '${(_currentItem.interestRate ?? 0).toStringAsFixed(1)}%',
                                  isDark: isDark,
                                ),
                                _buildSummaryItem(
                                  label: context.translate('total_interest'),
                                  value: CurrencyKpiUtils.formatAmount(
                                    totalInterest,
                                    currency,
                                  ),
                                  isDark: isDark,
                                  color: Colors.amber.shade800,
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _buildSummaryItem(
                                  label: context.translate('total_cost'),
                                  value: CurrencyKpiUtils.formatAmount(
                                    totalCost,
                                    currency,
                                  ),
                                  isDark: isDark,
                                  isBold: true,
                                ),
                                _buildSummaryItem(
                                  label: context.translate('monthly_quota'),
                                  value: CurrencyKpiUtils.formatAmount(
                                    _schedule.isNotEmpty
                                        ? _schedule.first.quotaAmount
                                        : 0.0,
                                    currency,
                                  ),
                                  isDark: isDark,
                                  color: primary,
                                  isBold: true,
                                ),
                                _buildSummaryItem(
                                  label: context.translate('quotas_progress'),
                                  value: '$paidQuotas / $totalQuotas',
                                  isDark: isDark,
                                  color: paidQuotas == totalQuotas
                                      ? Colors.green
                                      : primary,
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _buildSummaryItem(
                              label: context.translate('principal'),
                              value: CurrencyKpiUtils.formatAmount(
                                _currentItem.amount,
                                currency,
                              ),
                              isDark: isDark,
                            ),
                            _buildDivider(primary),
                            _buildSummaryItem(
                              label: context.translate('interest_rate'),
                              value:
                                  '${(_currentItem.interestRate ?? 0).toStringAsFixed(1)}%',
                              isDark: isDark,
                            ),
                            _buildDivider(primary),
                            _buildSummaryItem(
                              label: context.translate('total_interest'),
                              value: CurrencyKpiUtils.formatAmount(
                                totalInterest,
                                currency,
                              ),
                              isDark: isDark,
                              color: Colors.amber.shade800,
                            ),
                            _buildDivider(primary),
                            _buildSummaryItem(
                              label: context.translate('total_cost'),
                              value: CurrencyKpiUtils.formatAmount(
                                totalCost,
                                currency,
                              ),
                              isDark: isDark,
                              isBold: true,
                            ),
                            _buildDivider(primary),
                            _buildSummaryItem(
                              label: context.translate('monthly_quota'),
                              value: CurrencyKpiUtils.formatAmount(
                                _schedule.isNotEmpty
                                    ? _schedule.first.quotaAmount
                                    : 0.0,
                                currency,
                              ),
                              isDark: isDark,
                              color: primary,
                              isBold: true,
                            ),
                            _buildDivider(primary),
                            _buildSummaryItem(
                              label: context.translate('quotas_progress'),
                              value: '$paidQuotas / $totalQuotas',
                              isDark: isDark,
                              color: paidQuotas == totalQuotas
                                  ? Colors.green
                                  : primary,
                            ),
                          ],
                        ),
                );
              },
            ),
          ),

          // Next Due Banner (with collect action)
          if (nextDueQuota != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.notification_important_outlined,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${context.translate('next_quota_due')}: Quota #${nextDueQuota.quotaNumber} (${DateFormat(dayMonthYearFormat).format(nextDueQuota.dueDate)})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? white : LightColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${context.translate('amount')}: ${CurrencyKpiUtils.formatAmount(nextDueQuota.quotaAmount, currency)}  (${context.translate('principal')}: ${CurrencyKpiUtils.formatAmount(nextDueQuota.principal, currency)} | ${context.translate('interest')}: ${CurrencyKpiUtils.formatAmount(nextDueQuota.interest, currency)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _onPayNextQuota(nextDueQuota),
                      icon: const Icon(Icons.payment, size: 14),
                      label: Text(
                        '${context.translate('collect_quota')} #${nextDueQuota.quotaNumber}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        visualDensity: VisualDensity.compact,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.translate('all_quotas_collected'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 6),

          // Scrollable Amortization Table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 14.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 720,
                        child: Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            child: DataTable(
                              headingRowHeight: 38,
                              dataRowMinHeight: 34,
                              dataRowMaxHeight: 40,
                              columnSpacing: 16,
                              headingRowColor: WidgetStateProperty.all(
                                isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : const Color(0xFFF3F4F6),
                              ),
                              columns: <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    context.translate('quota_number'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    context.translate('date_due'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: Text(
                                    context.translate('monthly_quota'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: Text(
                                    context.translate('principal'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: Text(
                                    context.translate('interest'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: Text(
                                    context.translate('remaining_balance'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    context.translate('status'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                              rows: _schedule.map((
                                final AmortizationScheduleItem q,
                              ) {
                                final bool isNextDue =
                                    nextDueQuota?.quotaNumber == q.quotaNumber;
                                return DataRow(
                                  color:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        final Set<WidgetState> states,
                                      ) {
                                        if (q.isPaid) {
                                          return Colors.green.withValues(
                                            alpha: 0.05,
                                          );
                                        }
                                        if (isNextDue) {
                                          return Colors.blue.withValues(
                                            alpha: 0.08,
                                          );
                                        }
                                        return null;
                                      }),
                                  cells: <DataCell>[
                                    DataCell(
                                      Text(
                                        '#${q.quotaNumber}',
                                        style: TextStyle(
                                          fontWeight: isNextDue
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        DateFormat(
                                          dayMonthYearFormat,
                                        ).format(q.dueDate),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isNextDue
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        q.quotaAmount.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: isNextDue
                                              ? Colors.blue.shade700
                                              : null,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        q.principal.toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        q.interest.toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        q.remainingBalance.toStringAsFixed(2),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      q.isPaid
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                context.translate('received'),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            )
                                          : isNextDue
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(
                                                  alpha: 0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                context.translate('pending'),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              context.translate('pending'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDark
                                                    ? DarkColors.textSecondary
                                                    : LightColors.textSecondary,
                                              ),
                                            ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer Close
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 14.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                child: CustomButton(
                  text: context.translate('close'),
                  isPrimary: false,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required final String label,
    required final String value,
    required final bool isDark,
    final Color? color,
    final bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? (isDark ? white : LightColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(final Color primary) {
    return Container(
      width: 1,
      height: 28,
      color: primary.withValues(alpha: 0.2),
    );
  }
}
