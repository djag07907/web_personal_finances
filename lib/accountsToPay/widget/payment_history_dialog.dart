import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_payment.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/utils/account_to_pay_utils.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class PaymentHistoryDialog extends StatefulWidget {
  final AccountToPayItem item;
  final void Function(AccountToPayItem updatedItem) onPaymentRemoved;

  const PaymentHistoryDialog({
    super.key,
    required this.item,
    required this.onPaymentRemoved,
  });

  static Future<void> show({
    required final BuildContext context,
    required final AccountToPayItem item,
    required final void Function(AccountToPayItem) onPaymentRemoved,
  }) {
    return showDialog<void>(
      context: context,
      builder: (final BuildContext ctx) {
        return Dialog(
          backgroundColor: transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: PaymentHistoryDialog(
            item: item,
            onPaymentRemoved: onPaymentRemoved,
          ),
        );
      },
    );
  }

  @override
  State<PaymentHistoryDialog> createState() => _PaymentHistoryDialogState();
}

class _PaymentHistoryDialogState extends State<PaymentHistoryDialog> {
  late AccountToPayItem _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  Future<bool?> _showConfirmation(final String content) async {
    final Completer<bool?> completer = Completer<bool?>();
    CustomConfirmationDialog.showCustomConfirmationDialog(
      context,
      confirmationText: content,
      onPrimaryButtonTap: () {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onSecondaryButtonTap: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    ).then((_) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });
    return completer.future;
  }

  void _removePayment(final AccountToPayPayment payment) async {
    final bool? confirmed = await _showConfirmation(
      context.translate('confirm_delete_payment'),
    );

    if (confirmed == true && mounted) {
      final AccountToPayItem updated = AccountToPayUtils.removePayment(
        item: _currentItem,
        paymentId: payment.id,
      );
      setState(() {
        _currentItem = updated;
      });
      widget.onPaymentRemoved(updated);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark ? DarkColors.primary : LightColors.primary;
    final String currency = _currentItem.currency;
    final List<AccountToPayPayment> payments = _currentItem.payments;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxDialogHeight = (screenHeight * 0.88).clamp(360.0, 620.0);
    final double dialogWidth = (screenWidth - 32.0).clamp(320.0, 560.0);

    return Container(
      width: dialogWidth,
      constraints: BoxConstraints(maxWidth: 560, maxHeight: maxDialogHeight),
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
      padding: const EdgeInsets.all(22.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.translate('payment_history'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? white : LightColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentItem.creditorName,
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
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: isDark ? DarkColors.textSecondary : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${context.translate('total_debt')}: ${CurrencyKpiUtils.formatAmount(_currentItem.amount, currency)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? DarkColors.textSecondary : Colors.grey[700],
                  ),
                ),
                Text(
                  '${context.translate('remaining_balance')}: ${CurrencyKpiUtils.formatAmount(_currentItem.remainingBalance, currency)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Payments List
          Expanded(
            child: payments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: isDark
                                ? DarkColors.textSecondary
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            context.translate('no_payments_yet'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: payments.length,
                    separatorBuilder:
                        (final BuildContext context, final int index) =>
                            Divider(
                              height: 1,
                              color: isDark
                                  ? DarkColors.border
                                  : const Color(0xFFE5E7EB),
                            ),
                    itemBuilder: (final BuildContext ctx, final int index) {
                      final AccountToPayPayment payment = payments[index];
                      final String dateStr = DateFormat(
                        dayMonthYearFormat,
                      ).format(payment.paymentDate);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    CurrencyKpiUtils.formatAmount(
                                      payment.amount,
                                      currency,
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? white
                                          : LightColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$dateStr${payment.paymentMethod != null ? " • ${payment.paymentMethod}" : ""}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? DarkColors.textSecondary
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  if (payment.notes != null &&
                                      payment.notes!.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 2),
                                    Text(
                                      payment.notes!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: context.translate('delete_payment'),
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red[400],
                              ),
                              onPressed: () => _removePayment(payment),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.translate('close'),
                style: TextStyle(color: primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
