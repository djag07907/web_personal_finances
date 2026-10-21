import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class ExpenseToIncomeBar extends StatelessWidget {
  final double totalIncomes;
  final double totalExpenses;
  final String currency;

  const ExpenseToIncomeBar({
    super.key,
    required this.totalIncomes,
    required this.totalExpenses,
    this.currency = hnlCurrency,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 700;

    final double percentage = (totalIncomes > 0)
        ? (totalExpenses / totalIncomes) * 100
        : 0.0;

    Color barColor;
    String feedbackText;
    String statusLabel;
    Color statusBgColor;

    if (percentage < 20) {
      barColor = healthyGreen;
      statusLabel = context.translate('status_optimal');
      statusBgColor = isDark
          ? healthyGreen.withValues(alpha: 0.2)
          : const Color(0xFFE6FBF4);
      final String raw = context.translate('expenses_low');
      feedbackText = raw.replaceAll(
        '{percentage}',
        percentage.toStringAsFixed(1),
      );
    } else if (percentage < 40) {
      barColor = cautionOrange;
      statusLabel = context.translate('status_moderate');
      statusBgColor = isDark
          ? cautionOrange.withValues(alpha: 0.2)
          : const Color(0xFFFFF7ED);
      final String raw = context.translate('expenses_moderate');
      feedbackText = raw.replaceAll(
        '{percentage}',
        percentage.toStringAsFixed(1),
      );
    } else {
      barColor = unhealthyRed;
      statusLabel = context.translate('status_high_burn');
      statusBgColor = isDark
          ? unhealthyRed.withValues(alpha: 0.2)
          : const Color(0xFFFEF2F2);
      final String raw = context.translate('expenses_high');
      feedbackText = raw.replaceAll(
        '{percentage}',
        percentage.toStringAsFixed(1),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 14.0 : 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header row with Icon, Title and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.speed_rounded, color: barColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        context.translate('cash_flow_health_title'),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.translate('cash_flow_health_subtitle'),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: barColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: barColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$statusLabel • ${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress track
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDark ? DarkColors.surfaceLight : const Color(0xFFEDF2F7),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percentage / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: barColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle / Feedback and Values
          if (isSmallScreen) ...<Widget>[
            Text(
              feedbackText,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${context.translate('incomes')}: ${CurrencyKpiUtils.formatAmount(totalIncomes, currency)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: healthyGreen,
                  ),
                ),
                Text(
                  '${context.translate('burn')}: ${CurrencyKpiUtils.formatAmount(totalExpenses, currency)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ] else ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${context.translate('incomes')}: ${CurrencyKpiUtils.formatAmount(totalIncomes, currency)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: healthyGreen,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      feedbackText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text(
                  '${context.translate('burn')}: ${CurrencyKpiUtils.formatAmount(totalExpenses, currency)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
