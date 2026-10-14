import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/amortization_schedule_item.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/calendar/calendar_widget.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_input.dart';
import 'package:web_personal_finances/commons/inputs/custom_label_selector.dart';
import 'package:web_personal_finances/commons/utils/account_to_pay_utils.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/commons/utils/loan_amortization_utils.dart';
import 'package:web_personal_finances/commons/utils/money_input_formatter.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class MakePaymentDialog extends StatefulWidget {
  final AccountToPayItem item;
  final void Function(AccountToPayItem updatedItem) onPaymentRecorded;

  const MakePaymentDialog({
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
      barrierDismissible: false,
      builder: (final BuildContext ctx) {
        return Dialog(
          backgroundColor: transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: MakePaymentDialog(
            item: item,
            onPaymentRecorded: onPaymentRecorded,
          ),
        );
      },
    );
  }

  @override
  State<MakePaymentDialog> createState() => _MakePaymentDialogState();
}

class _MakePaymentDialogState extends State<MakePaymentDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedMethod;
  AmortizationScheduleItem? _nextLoanQuota;

  final List<String> _methods = <String>[
    'Cash',
    'Bank Transfer',
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
          LoanAmortizationUtils.generateSchedule(widget.item);
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

    final AccountToPayItem updated = AccountToPayUtils.applyPayment(
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
          // 1. Header (fixed at top)
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
                        context.translate('make_payment'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? white : LightColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.creditorName,
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

          // 2. Scrollable Form Content
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
                            label: context.translate('total_debt'),
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
                            label: context.translate('paid'),
                            amount: CurrencyKpiUtils.formatAmount(
                              widget.item.totalPaid,
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
                    const SizedBox(height: 16),

                    // Amount to pay Input with trailing quick action buttons
                    CustomLabelInput(
                      label: context.translate('amount_to_pay'),
                      trailingLabel: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (_nextLoanQuota != null) ...<Widget>[
                            InkWell(
                              onTap: _fillQuotaAmount,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  '#${_nextLoanQuota!.quotaNumber}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          InkWell(
                            onTap: _fillFullBalance,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.bolt, size: 13, color: primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.translate('pay_full_balance'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        final double? parsed = double.tryParse(
                          value.replaceAll(',', emptyString),
                        );
                        if (parsed == null || parsed <= 0) {
                          return context.translate('please_enter_amount');
                        }
                        return null;
                      },
                      controller: _amountController,
                    ),

                    // Payment Date picker
                    CustomLabelInput(
                      label: context.translate('payment_date'),
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
                      hintText: 'e.g. Quota #3 or partial transfer',
                      validator: (final String? value) => null,
                      controller: _notesController,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Fixed Bottom Action Buttons
          Divider(
            height: 1,
            color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 22.0,
              vertical: 14.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 100),
                  child: SizedBox(
                    height: 40,
                    child: CustomButton(
                      text: context.translate('cancel'),
                      isPrimary: false,
                      isAdd: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 150),
                  child: SizedBox(
                    height: 40,
                    child: CustomButton(
                      text: context.translate('confirm_payment'),
                      isPrimary: true,
                      isAdd: true,
                      onPressed: _onConfirm,
                    ),
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
            fontSize: 10,
            color: isDark ? DarkColors.textSecondary : Colors.grey[600],
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
