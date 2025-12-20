part of 'home_body.dart';

class RecentTransactionsCard extends StatelessWidget {
  final List<TransactionItem> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Color(0xFFF0F4F3),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Color(0xFFF0F4F3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? white : LightColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: LightColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: transactions.length,
              itemBuilder: (final BuildContext context, final int index) {
                final TransactionItem transaction = transactions[index];
                return _buildTransactionItem(
                  context,
                  transaction,
                  isDark,
                  isSmallScreen,
                  isLast: index == transactions.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    final BuildContext context,
    final TransactionItem transaction,
    final bool isDark,
    final bool isSmall, {
    required final bool isLast,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Color(0xFFF0F4F3),
                ),
              ),
      ),
      child: Material(
        color: transparent,
        child: InkWell(
          onTap: () {
            // Handle transaction tap
          },
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            child: Row(
              children: <Widget>[
                Container(
                  width: isSmall ? 36 : 40,
                  height: isSmall ? 36 : 40,
                  decoration: BoxDecoration(
                    color: transaction.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.iconColor,
                    size: isSmall ? 18 : 20,
                  ),
                ),
                SizedBox(width: isSmall ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? white : LightColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${transaction.category} • ${transaction.date}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 11 : 12,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${transaction.isIncome ? "+" : "-"} \$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome
                        ? LightColors.primary
                        : (isDark ? white : LightColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
