import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/accountsToPay/widget/make_payment_dialog.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class AmortizationScheduleDialog extends StatefulWidget {
  final AccountToPayItem item;
  final void Function(AccountToPayItem updatedItem) onPaymentRecorded;

  const AmortizationScheduleDialog({
    super.key,
    required this.item,
    required this.onPaymentRecorded,
  });

  static Future<void> show({
    required final BuildContext context,
    required final AccountToPayItem item,
    required final void Function(AccountToPayItem) onPaymentRecorded,
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
  late AccountToPayItem _currentItem;
  late List<AmortizationScheduleItem> _schedule;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _schedule = LoanAmortizationUtils.generateSchedule(_currentItem);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _onPayNextQuota(final AmortizationScheduleItem nextQuota) {
    MakePaymentDialog.show(
      context: context,
      item: _currentItem,
      onPaymentRecorded: (final AccountToPayItem updated) {
        setState(() {
          _currentItem = updated;
          _schedule = LoanAmortizationUtils.generateSchedule(updated);
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
                            size: 22,
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
                        '${_currentItem.creditorName} • ${CurrencyKpiUtils.formatAmount(_currentItem.amount, currency)} (${_currentItem.totalQuotas ?? _schedule.length} months @ ${_currentItem.interestRate ?? 0}% APR • ${_currentItem.interestType.toTranslate(context)})',
                        style: TextStyle(
                          fontSize: 13,
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

          // Summary KPI Strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            color: isDark
                ? DarkColors.background.withValues(alpha: 0.5)
                : const Color(0xFFF9FAFB),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.spaceAround,
              children: <Widget>[
                _buildSummaryKpi(
                  label: context.translate('principal'),
                  value: CurrencyKpiUtils.formatAmount(
                    _currentItem.amount,
                    currency,
                  ),
                  isDark: isDark,
                  primary: primary,
                ),
                _buildSummaryKpi(
                  label: context.translate('total_interest'),
                  value: CurrencyKpiUtils.formatAmount(totalInterest, currency),
                  isDark: isDark,
                  primary: Colors.amber.shade700,
                ),
                _buildSummaryKpi(
                  label: context.translate('total_cost'),
                  value: CurrencyKpiUtils.formatAmount(totalCost, currency),
                  isDark: isDark,
                  primary: isDark ? white : LightColors.textPrimary,
                ),
                _buildSummaryKpi(
                  label: context.translate('monthly_quota'),
                  value: _schedule.isNotEmpty
                      ? CurrencyKpiUtils.formatAmount(
                          _schedule.first.quotaAmount,
                          currency,
                        )
                      : '-',
                  isDark: isDark,
                  primary: Colors.blue.shade700,
                ),
                _buildSummaryKpi(
                  label: context.translate('quotas_progress'),
                  value: '$paidQuotas / $totalQuotas',
                  isDark: isDark,
                  primary: paidQuotas == totalQuotas ? Colors.green : primary,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
          ),

          // Schedule Table
          Expanded(
            child: _schedule.isEmpty
                ? Center(
                    child: Text(
                      'No amortization schedule available for this item.',
                      style: TextStyle(
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  )
                : Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 780,
                        child: Column(
                          children: <Widget>[
                            // Table Header Row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10.0,
                              ),
                              color: isDark
                                  ? DarkColors.surface
                                  : const Color(0xFFF3F4F6),
                              child: Row(
                                children: <Widget>[
                                  _buildHeaderCell('#', flex: 1),
                                  _buildHeaderCell(
                                    context.translate('date_due'),
                                    flex: 3,
                                  ),
                                  _buildHeaderCell(
                                    context.translate('monthly_quota'),
                                    flex: 3,
                                  ),
                                  _buildHeaderCell(
                                    context.translate('principal'),
                                    flex: 3,
                                  ),
                                  _buildHeaderCell(
                                    context.translate('interest'),
                                    flex: 3,
                                  ),
                                  _buildHeaderCell(
                                    context.translate('remaining_balance'),
                                    flex: 3,
                                  ),
                                  _buildHeaderCell(
                                    context.translate('status'),
                                    flex: 3,
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? DarkColors.border
                                  : const Color(0xFFE5E7EB),
                            ),

                            // Table Body Rows
                            Expanded(
                              child: Scrollbar(
                                controller: _verticalScrollController,
                                thumbVisibility: true,
                                child: ListView.separated(
                                  controller: _verticalScrollController,
                                  itemCount: _schedule.length,
                                  separatorBuilder:
                                      (
                                        final BuildContext context,
                                        final int index,
                                      ) => Divider(
                                        height: 1,
                                        color: isDark
                                            ? DarkColors.border.withValues(
                                                alpha: 0.5,
                                              )
                                            : const Color(0xFFF3F4F6),
                                      ),
                                  itemBuilder:
                                      (
                                        final BuildContext ctx,
                                        final int index,
                                      ) {
                                        final AmortizationScheduleItem quota =
                                            _schedule[index];
                                        final bool isNext =
                                            nextDueQuota?.quotaNumber ==
                                            quota.quotaNumber;

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 9.0,
                                          ),
                                          color: quota.isPaid
                                              ? (Colors.green.withValues(
                                                  alpha: 0.04,
                                                ))
                                              : (isNext
                                                    ? (primary.withValues(
                                                        alpha: 0.06,
                                                      ))
                                                    : (index.isEven
                                                          ? (isDark
                                                                ? DarkColors
                                                                      .background
                                                                      .withValues(
                                                                        alpha:
                                                                            0.2,
                                                                      )
                                                                : const Color(
                                                                    0xFFFAFAFA,
                                                                  ))
                                                          : transparent)),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  '${quota.quotaNumber}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? white
                                                        : LightColors
                                                              .textPrimary,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  DateFormat(
                                                    dayMonthYearFormat,
                                                  ).format(quota.dueDate),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  CurrencyKpiUtils.formatAmount(
                                                    quota.quotaAmount,
                                                    currency,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  CurrencyKpiUtils.formatAmount(
                                                    quota.principal,
                                                    currency,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade700,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  CurrencyKpiUtils.formatAmount(
                                                    quota.interest,
                                                    currency,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.amber.shade800,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  CurrencyKpiUtils.formatAmount(
                                                    quota.remainingBalance,
                                                    currency,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: _buildStatusBadge(
                                                    quota: quota,
                                                    isNext: isNext,
                                                    isDark: isDark,
                                                    primary: primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),

          Divider(
            height: 1,
            color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (nextDueQuota != null && !_currentItem.isFullyPaid)
                  Row(
                    children: <Widget>[
                      Icon(Icons.event_note, size: 16, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        '${context.translate('next_quota_due')}: #${nextDueQuota.quotaNumber} (${DateFormat(dayMonthYearFormat).format(nextDueQuota.dueDate)})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? white : LightColors.textPrimary,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    context.translate('all_quotas_paid'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                Row(
                  spacing: 12,
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      height: 38,
                      child: CustomButton(
                        text: context.translate('close'),
                        isPrimary: false,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    if (nextDueQuota != null && !_currentItem.isFullyPaid)
                      SizedBox(
                        width: 140,
                        height: 38,
                        child: CustomButton(
                          text: context.translate('pay_quota'),
                          isPrimary: true,
                          onPressed: () => _onPayNextQuota(nextDueQuota),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryKpi({
    required final String label,
    required final String value,
    required final bool isDark,
    required final Color primary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(final String text, {required final int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: greyHard,
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required final AmortizationScheduleItem quota,
    required final bool isNext,
    required final bool isDark,
    required final Color primary,
  }) {
    final Color color;
    final IconData icon;
    final String label;

    if (quota.isPaid) {
      color = Colors.green;
      icon = Icons.check_circle_outline;
      label = context.translate('paid');
    } else if (isNext) {
      color = Colors.blue.shade700;
      icon = Icons.play_arrow_rounded;
      label = context.translate('next_quota_due');
    } else {
      color = Colors.amber.shade800;
      icon = Icons.schedule;
      label = context.translate('pending');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
