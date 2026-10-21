import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/account_receivable_utils.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class RecordPaymentDialog extends StatefulWidget {
  final AccountReceivableItem item;
  final void Function(AccountReceivableItem updatedItem) onPaymentRecorded;

  const RecordPaymentDialog({
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
      barrierDismissible: false,
      builder: (final BuildContext ctx) {
        return Dialog(
          backgroundColor: transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: RecordPaymentDialog(
            item: item,
            onPaymentRecorded: onPaymentRecorded,
          ),
        );
      },
    );
  }

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedMethod;
  AmortizationScheduleItem? _nextLoanQuota;

  final List<String> _methods = <String>[
    'Bank Transfer',
    'Cash',
    'Debit Card',
    'Credit Card',
    'Check',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final double remaining = widget.item.remainingBalance;

    if (widget.item.isLoanAccount) {
      final List<AmortizationScheduleItem> schedule =
          LoanAmortizationUtils.generateReceivableSchedule(widget.item);
      _nextLoanQuota = LoanAmortizationUtils.getNextDueQuota(schedule);
    }

    if (_nextLoanQuota != null) {
      final double quotaAmt = _nextLoanQuota!.quotaAmount <= remaining
          ? _nextLoanQuota!.quotaAmount
          : remaining;
      _amountController.text = quotaAmt.toStringAsFixed(2);
    } else {
      _amountController.text = remaining > 0
          ? remaining.toStringAsFixed(2)
          : widget.item.amount.toStringAsFixed(2);
    }

    _dateController.text = DateFormat(dayMonthYearFormat).format(_selectedDate);
    _selectedMethod = widget.item.paymentMethod ?? 'Bank Transfer';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _fillFullBalance() {
    setState(() {
      _amountController.text = widget.item.remainingBalance.toStringAsFixed(2);
    });
  }

  void _fillQuotaAmount() {
    if (_nextLoanQuota != null) {
      final double remaining = widget.item.remainingBalance;
      final double quotaAmt = _nextLoanQuota!.quotaAmount <= remaining
          ? _nextLoanQuota!.quotaAmount
          : remaining;
      setState(() {
        _amountController.text = quotaAmt.toStringAsFixed(2);
      });
    }
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final double enteredAmount =
        double.tryParse(_amountController.text.replaceAll(',', emptyString)) ??
        0.0;
    if (enteredAmount <= 0) {
      return;
    }

    final AccountReceivableItem updated = AccountReceivableUtils.applyPayment(
      item: widget.item,
      amount: enteredAmount,
      paymentDate: _selectedDate,
      paymentMethod: _selectedMethod,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    widget.onPaymentRecorded(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? DarkColors.primary : LightColors.primary;
    final String currency = widget.item.currency;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxDialogHeight = (screenHeight * 0.88).clamp(360.0, 680.0);
    final double dialogWidth = (screenWidth - 32.0).clamp(320.0, 480.0);

    return Container(
      width: dialogWidth,
      constraints: BoxConstraints(maxWidth: 480, maxHeight: maxDialogHeight),
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
        mainAxisSize: MainAxisSize.min,
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
                      Text(
                        context.translate('record_payment'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? white : LightColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.debtorName,
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

          // Scrollable Form Content
          Flexible(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22.0, 16.0, 22.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Balances card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _buildBalanceCol(
                            label: context.translate('total_receivable'),
                            amount: CurrencyKpiUtils.formatAmount(
                              widget.item.amount,
                              currency,
                            ),
                            isDark: isDark,
                            color: isDark ? white : LightColors.textPrimary,
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: primary.withValues(alpha: 0.3),
                          ),
                          _buildBalanceCol(
                            label: context.translate('received'),
                            amount: CurrencyKpiUtils.formatAmount(
                              widget.item.totalCollected,
                              currency,
                            ),
                            isDark: isDark,
                            color: Colors.green,
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: primary.withValues(alpha: 0.3),
                          ),
                          _buildBalanceCol(
                            label: context.translate('remaining_balance'),
                            amount: CurrencyKpiUtils.formatAmount(
                              widget.item.remainingBalance,
                              currency,
                            ),
                            isDark: isDark,
                            color: primary,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    if (_nextLoanQuota != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.calendar_month,
                                      size: 14,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${context.translate('next_quota_due')}: #${_nextLoanQuota!.quotaNumber} (${DateFormat(dayMonthYearFormat).format(_nextLoanQuota!.dueDate)})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? white
                                            : LightColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyKpiUtils.formatAmount(
                                    _nextLoanQuota!.quotaAmount,
                                    currency,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${context.translate('principal')}: ${CurrencyKpiUtils.formatAmount(_nextLoanQuota!.principal, currency)}  •  ${context.translate('interest')}: ${CurrencyKpiUtils.formatAmount(_nextLoanQuota!.interest, currency)}',
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
                    ],

                    const SizedBox(height: 14),

                    // Quick buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: _fillFullBalance,
                          icon: const Icon(Icons.all_inclusive, size: 14),
                          label: Text(
                            context.translate('receive_full_balance'),
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (_nextLoanQuota != null) ...<Widget>[
                          OutlinedButton.icon(
                            onPressed: _fillQuotaAmount,
                            icon: const Icon(Icons.pin, size: 14),
                            label: Text(
                              '${context.translate('collect_quota')} #${_nextLoanQuota!.quotaNumber}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Amount input
                    CustomLabelInput(
                      label:
                          '${context.translate('amount_to_receive')} ($currency)',
                      controller: _amountController,
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <MoneyInputFormatter>[
                        MoneyInputFormatter(),
                      ],
                      validator: (final String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.translate('please_enter_amount');
                        }
                        final double? amt = double.tryParse(
                          value.replaceAll(',', emptyString),
                        );
                        if (amt == null || amt <= 0) {
                          return context.translate(
                            'please_enter_a_valid_number',
                          );
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Collection Date Picker
                    CustomLabelInput(
                      label: context.translate('date_received'),
                      hintText: context.translate('select_date'),
                      isReadOnly: true,
                      isCalendar: true,
                      onTap: () async {
                        final CustomCalendarDialog calendar =
                            CustomCalendarDialog();
                        final DateTime? selectedDate = await calendar
                            .showDateDialog(
                              context: context,
                              dateController: _dateController,
                            );
                        if (selectedDate != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                            _dateController.text = DateFormat(
                              dayMonthYearFormat,
                            ).format(selectedDate);
                          });
                        }
                      },
                      validator: (final String? value) => null,
                      controller: _dateController,
                    ),

                    // Payment Method
                    CustomLabelSelector(
                      label: context.translate('payment_method'),
                      hintText: context.translate('select_payment_method'),
                      validator: (final String? value) => null,
                      selectedValue: _selectedMethod,
                      items: _methods,
                      onChanged: (final String? value) {
                        setState(() {
                          _selectedMethod = value;
                        });
                      },
                    ),

                    // Notes
                    CustomLabelInput(
                      label:
                          '${context.translate('description')} (${context.translate('optional')})',
                      hintText: 'e.g. Quota #1 or partial transfer',
                      validator: (final String? value) => null,
                      controller: _notesController,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(22.0, 10.0, 22.0, 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: context.translate('cancel'),
                    isPrimary: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: context.translate('confirm_payment'),
                    isPrimary: true,
                    onPressed: _onConfirm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCol({
    required final String label,
    required final String amount,
    required final bool isDark,
    required final Color color,
    final bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
