import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/home/model/financial_data.dart';
import 'package:web_personal_finances/home/widget/indicator.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';
import 'package:web_personal_finances/resources/themes.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  int touchedIndex = -1;
  @override
  Widget build(final BuildContext context) {
    final FinancialData financialData = getFinancialData();
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildHeader(context),
            Expanded(
              child: CustomCardBody(
                isMain: true,
                title: context.translate('home'),
                body: _buildCharts(
                  financialData,
                ), // Pass financialData to the charts
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(final BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        height: 50.0,
        margin: EdgeInsets.only(top: 10.0),
        width: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
          color: lightTheme.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(300.0),
            bottomLeft: Radius.circular(300.0),
          ),
        ),
        child: Center(
          child: Text(
            'Welcome to your personal finances, {username}',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: fontSize24,
                  color: white,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharts(final FinancialData financialData) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: _buildPieChart(financialData)), // Left Pie Chart
            SizedBox(width: 16), // Spacing between charts
            Expanded(child: _buildPieChart(financialData)), // Right Pie Chart
          ],
        ),
        _buildIndicators(financialData), // Show indicators below the charts
      ],
    );
  }

  Widget _buildPieChart(final FinancialData financialData) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (
              final FlTouchEvent event,
              final PieTouchResponse? pieTouchResponse,
            ) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections:
              showingSections(financialData), // Pass financialData to sections
        ),
      ),
    );
  }

  Widget _buildIndicators(final FinancialData financialData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Indicator(
          color: Colors.green,
          text: 'Incomes: ${financialData.totalIncomes}',
          isSquare: true,
        ),
        SizedBox(height: 4),
        Indicator(
          color: Colors.red,
          text: 'Expenses: ${financialData.totalExpenses}',
          isSquare: true,
        ),
        SizedBox(height: 4),
        // Add more indicators as needed
        SizedBox(height: 18),
      ],
    );
  }

  List<PieChartSectionData> showingSections(final FinancialData financialData) {
    return List.generate(2, (final int i) {
      final bool isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25.0 : 16.0;
      final double radius = isTouched ? 60.0 : 50.0;
      const List<Shadow> shadows = <Shadow>[
        Shadow(color: Colors.black, blurRadius: 2),
      ];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green, // Income color
            value: financialData.totalIncomes, // Use actual income data
            title: '${financialData.totalIncomes}', // Display total income
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red, // Expense color
            value: financialData.totalExpenses, // Use actual expense data
            title: '${financialData.totalExpenses}', // Display total expenses
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: black,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}

FinancialData getFinancialData() {
  // Replace with your actual data retrieval logic
  return FinancialData(
    totalExpensesLempiras: 5000,
    totalExpensesDollars: 200,
    totalIncomesLempiras: 10000,
    totalIncomesDollars: 300,
  );
}
