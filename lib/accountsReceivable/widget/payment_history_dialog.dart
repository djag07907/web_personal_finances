import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_payment.dart';
import 'package:web_personal_finances/commons/dialog/custom_confirmation_dialog.dart';
import 'package:web_personal_finances/commons/utils/account_receivable_utils.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class PaymentHistoryDialog extends StatefulWidget {
  final AccountReceivableItem item;
  final void Function(AccountReceivableItem updatedItem) onPaymentRemoved;

  const PaymentHistoryDialog({
    super.key,
    required this.item,
    required this.onPaymentRemoved,
  });

  static Future<void> show({
    required final BuildContext context,
    required final AccountReceivableItem item,
    required final void Function(AccountReceivableItem) onPaymentRemoved,
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
  late AccountReceivableItem _currentItem;

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

  void _removePayment(final AccountReceivablePayment payment) async {
    final bool? confirmed = await _showConfirmation(
      context.translate('confirm_delete_payment'),
    );

    if (confirmed == true && mounted) {
      final AccountReceivableItem updated =
          AccountReceivableUtils.removePayment(
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
    final List<AccountReceivablePayment> payments = _currentItem.payments;
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
                      context.translate('collection_history'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? white : LightColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentItem.debtorName,
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
          const SizedBox(height: 12),

          // Balance status banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildCol(
                  context.translate('total_receivable'),
                  CurrencyKpiUtils.formatAmount(_currentItem.amount, currency),
                  isDark,
                  isDark ? white : LightColors.textPrimary,
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: primary.withValues(alpha: 0.3),
                ),
                _buildCol(
                  context.translate('received'),
                  CurrencyKpiUtils.formatAmount(
                    _currentItem.totalCollected,
                    currency,
                  ),
                  isDark,
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: primary.withValues(alpha: 0.3),
                ),
                _buildCol(
                  context.translate('remaining_balance'),
                  CurrencyKpiUtils.formatAmount(
                    _currentItem.remainingBalance,
                    currency,
                  ),
                  isDark,
                  primary,
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Payments list
          Text(
            '${context.translate('recorded_collections')} (${payments.length})',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? white : LightColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: payments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        context.translate('no_payments_yet'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: payments.length,
                    separatorBuilder: (final BuildContext _, final int index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (final BuildContext ctx, final int index) {
                      final AccountReceivablePayment p = payments[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkColors.surface
                              : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? DarkColors.border
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        CurrencyKpiUtils.formatAmount(
                                          p.amount,
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
                                      Text(
                                        DateFormat(
                                          dayMonthYearFormat,
                                        ).format(p.paymentDate),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? DarkColors.textSecondary
                                              : LightColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (p.paymentMethod != null &&
                                      p.paymentMethod!.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 2),
                                    Text(
                                      p.paymentMethod!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                  if (p.notes != null &&
                                      p.notes!.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 2),
                                    Text(
                                      p.notes!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? DarkColors.textSecondary
                                            : LightColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              tooltip: context.translate('delete'),
                              onPressed: () => _removePayment(p),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCol(
    final String label,
    final String amount,
    final bool isDark,
    final Color color, {
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
