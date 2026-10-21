part of 'home_body.dart';

class FinancialBreakdownCard extends StatefulWidget {
  final List<CategoryBreakdownItem> expenseItems;
  final List<CategoryBreakdownItem> incomeItems;
  final double totalExpenses;
  final double totalIncomes;
  final String currency;

  const FinancialBreakdownCard({
    super.key,
    required this.expenseItems,
    required this.incomeItems,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.currency,
  });

  @override
  State<FinancialBreakdownCard> createState() => _FinancialBreakdownCardState();
}

class _FinancialBreakdownCardState extends State<FinancialBreakdownCard> {
  int _selectedTabIndex = 0; // 0 for Expenses, 1 for Incomes

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    final bool isExpensesTab = _selectedTabIndex == 0;
    final List<CategoryBreakdownItem> activeItems = isExpensesTab
        ? widget.expenseItems
        : widget.incomeItems;
    final double activeTotal = isExpensesTab
        ? widget.totalExpenses
        : widget.totalIncomes;
    final String activeLabel = isExpensesTab
        ? context.translate('expenses')
        : context.translate('incomes');

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
      padding: EdgeInsets.all(isSmallScreen ? 14.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header with Title, Subtitle and Segmented Tab Controls
          _buildHeader(context, isDark, isSmallScreen),
          const SizedBox(height: 20),

          // Content: Empty State or Chart + Table
          if (activeItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: EmptyContentWidget(
                  icon: isExpensesTab
                      ? Icons.pie_chart_outline
                      : Icons.donut_large_outlined,
                  title: context
                      .translate('no_records_recorded')
                      .replaceAll('{category}', activeLabel),
                  subtitle: context
                      .translate('no_records_recorded_desc')
                      .replaceAll('{category}', activeLabel),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder:
                  (
                    final BuildContext context,
                    final BoxConstraints constraints,
                  ) {
                    final bool useHorizontalLayout =
                        constraints.maxWidth >= 650;

                    if (useHorizontalLayout) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Chart on left
                          SizedBox(
                            width: 220,
                            child: Center(
                              child: _buildDonutChart(
                                activeItems,
                                activeTotal,
                                isDark,
                                isSmall: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Responsive table on right
                          Expanded(
                            child: _buildBreakdownTable(
                              activeItems,
                              activeTotal,
                              isDark,
                              isSmallScreen: false,
                            ),
                          ),
                        ],
                      );
                    }

                    // Stacked layout for mobile / narrow views
                    return Column(
                      children: <Widget>[
                        Center(
                          child: _buildDonutChart(
                            activeItems,
                            activeTotal,
                            isDark,
                            isSmall: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildBreakdownTable(
                          activeItems,
                          activeTotal,
                          isDark,
                          isSmallScreen: true,
                        ),
                      ],
                    );
                  },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final bool isDark,
    final bool isSmallScreen,
  ) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final bool shouldStackHeader = constraints.maxWidth < 500;

        final Widget titleWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: LightColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pie_chart_rounded,
                color: LightColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.translate('financial_distribution_title'),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.translate('financial_distribution_subtitle'),
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
        );

        final Widget tabSelector = Container(
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surfaceLight : const Color(0xFFEDF2F7),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTabPill(
                title: context.translate('expenses'),
                count: widget.expenseItems.length,
                isSelected: _selectedTabIndex == 0,
                onTap: () => setState(() => _selectedTabIndex = 0),
                isDark: isDark,
              ),
              _buildTabPill(
                title: context.translate('incomes'),
                count: widget.incomeItems.length,
                isSelected: _selectedTabIndex == 1,
                onTap: () => setState(() => _selectedTabIndex = 1),
                isDark: isDark,
              ),
            ],
          ),
        );

        if (shouldStackHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              titleWidget,
              const SizedBox(height: 12),
              tabSelector,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[titleWidget, tabSelector],
        );
      },
    );
  }

  Widget _buildTabPill({
    required final String title,
    required final int count,
    required final bool isSelected,
    required final VoidCallback onTap,
    required final bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? DarkColors.primary : white)
              : transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? white : LightColors.primary)
                    : (isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary),
              ),
            ),
            if (count > 0) ...<Widget>[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? white.withValues(alpha: 0.2)
                            : LightColors.primary.withValues(alpha: 0.12))
                      : (isDark
                            ? DarkColors.surface
                            : Colors.grey.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isDark ? white : LightColors.primary)
                        : (isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart(
    final List<CategoryBreakdownItem> items,
    final double total,
    final bool isDark, {
    required final bool isSmall,
  }) {
    final double chartSize = isSmall ? 150 : 190;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SizedBox(
          width: chartSize,
          height: chartSize,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: chartSize * 0.32,
              startDegreeOffset: -90,
              sections: items.map((final CategoryBreakdownItem item) {
                return PieChartSectionData(
                  color: item.color,
                  value: item.percentage,
                  title: emptyString,
                  radius: isSmall ? 40 : 48,
                );
              }).toList(),
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        ),
        Container(
          width: chartSize * 0.60,
          height: chartSize * 0.60,
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surface : white,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                context.translate('total'),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  CurrencyKpiUtils.formatAmount(total, widget.currency),
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? white : LightColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownTable(
    final List<CategoryBreakdownItem> items,
    final double total,
    final bool isDark, {
    required final bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Table Header
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(
                  context.translate('category_col'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  context.translate('share_col'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  context.translate('amount_col'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? DarkColors.border : const Color(0xFFEDF2F7),
        ),
        const SizedBox(height: 6),

        // Table Rows
        ...items.map((final CategoryBreakdownItem item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            child: Row(
              children: <Widget>[
                // Category with color pill
                Expanded(
                  flex: 4,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.categoryName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? white : LightColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Share with progress badge
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                    ),
                  ),
                ),
                // Formatted Amount
                Expanded(
                  flex: 4,
                  child: Text(
                    CurrencyKpiUtils.formatAmount(item.amount, widget.currency),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? white : LightColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? DarkColors.border : const Color(0xFFEDF2F7),
        ),
        const SizedBox(height: 8),

        // Total Footer Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                context.translate('total_tracked'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              Text(
                CurrencyKpiUtils.formatAmount(total, widget.currency),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? white : LightColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
