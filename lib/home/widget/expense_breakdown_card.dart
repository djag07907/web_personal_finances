part of 'home_body.dart';

class ExpenseBreakdownCard extends StatelessWidget {
  final Map<String, double> expenseData;

  const ExpenseBreakdownCard({
    super.key,
    required this.expenseData,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    // final bool isMediumScreen = screenWidth >= 600 && screenWidth < 900;

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
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Expense Breakdown',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? white : LightColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
              child: LayoutBuilder(
                builder: (
                  final BuildContext context,
                  final BoxConstraints constraints,
                ) {
                  final bool useVerticalLayout =
                      constraints.maxWidth < 400 || isSmallScreen;

                  return useVerticalLayout
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildPieChart(context, isSmallScreen),
                            SizedBox(height: 24),
                            _buildLegend(context, isDark, isSmallScreen),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _buildPieChart(context, isSmallScreen),
                            SizedBox(width: 24),
                            Expanded(
                              child:
                                  _buildLegend(context, isDark, isSmallScreen),
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(final BuildContext context, final bool isSmall) {
    // Optimal chart size for balanced appearance
    final double chartSize = isSmall ? 140 : 180;

    return SizedBox(
      width: chartSize,
      height: chartSize,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 0,
          startDegreeOffset: -90,
          sections: _buildPieSections(isSmall),
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(
            touchCallback: (
              final FlTouchEvent event,
              final PieTouchResponse? pieTouchResponse,
            ) {},
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(final bool isSmall) {
    final List<Color> colors = <Color>[
      LightColors.primary,
      Color(0xFF81F4D1),
      Color(0xFF2D453D),
    ];

    final List<MapEntry<String, double>> entries = expenseData.entries.toList();
    final List<PieChartSectionData> sections = <PieChartSectionData>[];

    for (int i = 0; i < entries.length; i++) {
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: entries[i].value,
          title: '${entries[i].value.toStringAsFixed(0)}%',
          radius: isSmall ? 55 : 70,
          titleStyle: TextStyle(
            fontSize: isSmall ? 11 : 13,
            fontWeight: FontWeight.bold,
            color: i == 2 ? white : black,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(
    final BuildContext context,
    final bool isDark,
    final bool isSmall,
  ) {
    final List<Color> colors = <Color>[
      LightColors.primary,
      Color(0xFF81F4D1),
      Color(0xFF2D453D),
    ];

    final List<MapEntry<String, double>> entries = expenseData.entries.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .asMap()
          .entries
          .map((final MapEntry<int, MapEntry<String, double>> entry) {
        final int index = entry.key;
        final MapEntry<String, double> data = entry.value;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    data.key,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 14,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${data.value.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? white : LightColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
