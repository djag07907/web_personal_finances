part of 'home_body.dart';

class UpcomingBillsCard extends StatelessWidget {
  final List<BillItem> bills;
  final VoidCallback? onAddBill;

  const UpcomingBillsCard({
    super.key,
    required this.bills,
    this.onAddBill,
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
                  'Upcoming Bills',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? white : LightColors.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: onAddBill,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Color(0xFFF0F4F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: isDark ? white : LightColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              itemCount: bills.isEmpty ? 1 : bills.length,
              itemBuilder: (final BuildContext context, final int index) {
                if (bills.isEmpty) {
                  return _buildEmptyState(context, isDark, isSmallScreen);
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
                  child: _buildBillItem(
                    context,
                    bills[index],
                    isDark,
                    isSmallScreen,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(
    final BuildContext context,
    final BillItem bill,
    final bool isDark,
    final bool isSmall,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF13241E) : Color(0xFFFBFDFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Color(0xFFF0F4F3),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: isSmall ? 36 : 40,
            height: isSmall ? 36 : 40,
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  bill.dueMonth.toUpperCase(),
                  style: TextStyle(
                    fontSize: isSmall ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    color: bill.isPastDue
                        ? Colors.red[500]
                        : LightColors.textSecondary,
                  ),
                ),
                Text(
                  bill.dueDate,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? white : LightColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isSmall ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  bill.title,
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
                  bill.provider,
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
          SizedBox(width: isSmall ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '\$${bill.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? white : LightColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              InkWell(
                onTap: () {
                  // Handle pay action
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 10 : 12,
                    vertical: isSmall ? 5 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? white : LightColors.textPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? LightColors.textPrimary : white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    final BuildContext context,
    final bool isDark,
    final bool isSmall,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No more upcoming bills this month.',
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.w500,
            color:
                isDark ? DarkColors.textSecondary : LightColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
