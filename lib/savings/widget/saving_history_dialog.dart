import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/button/custom_button.dart';
import 'package:web_personal_finances/commons/enum/custom_saving_transaction_type.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/savings/model/saving_item.dart';
import 'package:web_personal_finances/savings/model/saving_registry_item.dart';
import 'package:web_personal_finances/savings/widget/record_transaction_dialog.dart';

class SavingHistoryDialog extends StatefulWidget {
  final SavingItem item;
  final void Function(SavingItem updatedItem) onHistoryUpdated;

  const SavingHistoryDialog({
    super.key,
    required this.item,
    required this.onHistoryUpdated,
  });

  static Future<void> show({
    required final BuildContext context,
    required final SavingItem item,
    required final void Function(SavingItem) onHistoryUpdated,
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
          child: SavingHistoryDialog(
            item: item,
            onHistoryUpdated: onHistoryUpdated,
          ),
        );
      },
    );
  }

  @override
  State<SavingHistoryDialog> createState() => _SavingHistoryDialogState();
}

class _SavingHistoryDialogState extends State<SavingHistoryDialog> {
  late SavingItem _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  void _onOpenDeposit() {
    RecordTransactionDialog.show(
      context: context,
      item: _currentItem,
      initialType: CustomSavingTransactionType.deposit,
      onTransactionRecorded:
          (final SavingItem updated, final SavingRegistryItem t) {
            setState(() {
              _currentItem = updated;
            });
            widget.onHistoryUpdated(updated);
          },
    );
  }

  void _onOpenWithdrawal() {
    RecordTransactionDialog.show(
      context: context,
      item: _currentItem,
      initialType: CustomSavingTransactionType.withdrawal,
      onTransactionRecorded:
          (final SavingItem updated, final SavingRegistryItem t) {
            setState(() {
              _currentItem = updated;
            });
            widget.onHistoryUpdated(updated);
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
    final double maxDialogHeight = (screenHeight * 0.85).clamp(420.0, 720.0);
    final double dialogWidth = (screenWidth - 32.0).clamp(340.0, 680.0);

    final List<SavingRegistryItem> sortedMovements =
        List<SavingRegistryItem>.from(_currentItem.registries)..sort(
          (final SavingRegistryItem a, final SavingRegistryItem b) =>
              b.date.compareTo(a.date),
        );

    return Container(
      width: dialogWidth,
      constraints: BoxConstraints(maxHeight: maxDialogHeight),
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
            padding: const EdgeInsets.fromLTRB(20.0, 18.0, 14.0, 14.0),
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
                            _currentItem.category.icon,
                            size: 20,
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _currentItem.name,
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
                        '${_currentItem.category.toTranslate(context)} • ${context.translate('saving_history')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
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
          ),
          Divider(
            height: 1,
            color: isDark ? DarkColors.border : const Color(0xFFE5E7EB),
          ),

          // Balance & Progress Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            context.translate('current_saved'),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyKpiUtils.formatAmount(
                              _currentItem.currentAmount,
                              currency,
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            context.translate('total_goal_amount'),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyKpiUtils.formatAmount(
                              _currentItem.goalAmount,
                              currency,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? white : LightColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_currentItem.progressPercent / 100.0).clamp(
                        0.0,
                        1.0,
                      ),
                      minHeight: 8,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _currentItem.isCompleted ? Colors.green : primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${_currentItem.progressPercent.toStringAsFixed(1)}% ${context.translate('progress').toLowerCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _currentItem.isCompleted
                              ? Colors.green
                              : primary,
                        ),
                      ),
                      Text(
                        _currentItem.targetDate != null
                            ? '${context.translate('target_date')}: ${DateFormat(dayMonthYearFormat).format(_currentItem.targetDate!)}'
                            : context.translate('no_target_date'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Movements header + Quick action buttons
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${context.translate('recorded_movements')} (${sortedMovements.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? white : LightColors.textPrimary,
                  ),
                ),
                Row(
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: _onOpenDeposit,
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.green,
                      ),
                      label: Text(
                        context.translate('deposit'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: _onOpenWithdrawal,
                      icon: const Icon(
                        Icons.remove,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      label: Text(
                        context.translate('withdrawal'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Movements List
          Expanded(
            child: sortedMovements.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 44,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.translate('no_movements_yet'),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                          if (_currentItem.amount > 0) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              '${context.translate('initial_deposit')}: ${CurrencyKpiUtils.formatAmount(_currentItem.amount, currency)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: sortedMovements.length,
                    separatorBuilder: (final BuildContext _, final int _) =>
                        const Divider(height: 1),
                    itemBuilder: (final BuildContext ctx, final int index) {
                      final SavingRegistryItem movement =
                          sortedMovements[index];
                      final bool isDeposit =
                          movement.type == CustomSavingTransactionType.deposit;

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: movement.type.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            movement.type.icon,
                            size: 16,
                            color: movement.type.color,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              movement.type.toTranslate(context),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? white : LightColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${isDeposit ? '+' : '-'}${CurrencyKpiUtils.formatAmount(movement.amount, currency)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: movement.type.color,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                movement.comment != null &&
                                        movement.comment!.isNotEmpty
                                    ? movement.comment!
                                    : DateFormat(
                                        dayMonthYearFormat,
                                      ).format(movement.date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              DateFormat(
                                dayMonthYearFormat,
                              ).format(movement.date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                height: 38,
                child: CustomButton(
                  text: context.translate('cancel'),
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
}
