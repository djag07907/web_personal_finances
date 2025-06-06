import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/cards/custom_card_item.dart';
import 'package:web_personal_finances/home/model/financial_data.dart';
import 'package:web_personal_finances/home/widget/expense_income_bar.dart';
import 'package:web_personal_finances/home/widget/indicator.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  int touchedIndex = -1;
  double? exchangeRate;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchExchangeRate();
  }

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
                ),
              ),
            ),
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        '1 USD = ${exchangeRate?.toStringAsFixed(2)} HNL',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
          color: LightColors.primary,
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
      spacing: 10,
      children: <Widget>[
        _buildCustomCardItems(),
        ExpenseToIncomeBar(
          totalIncomes: financialData.totalIncomesLempiras.toDouble(),
          totalExpenses: financialData.totalExpensesLempiras.toDouble(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: _buildPieChart(financialData)),
            SizedBox(width: 16),
            Expanded(child: _buildPieChart(financialData)),
          ],
        ),
        _buildIndicators(financialData),
      ],
    );
  }

  Widget _buildCustomCardItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CustomCardItem(
          leadingIcon: Icons.attach_money,
          titleText: 'Total Income',
          subtitleText: 'Lempiras: 10,000',
        ),
        CustomCardItem(
          leadingIcon: Icons.money_off,
          titleText: 'Total Expenses',
          subtitleText: 'Lempiras: 5,000',
        ),
        CustomCardItem(
          leadingIcon: Icons.pie_chart,
          titleText: 'Savings',
          subtitleText: 'Lempiras: 5,000',
        ),
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
          sections: showingSections(financialData),
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
        Shadow(color: black, blurRadius: 2),
      ];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: financialData.totalIncomes,
            title: '${financialData.totalIncomes}',
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
            color: Colors.red,
            value: financialData.totalExpenses,
            title: '${financialData.totalExpenses}',
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

  Future<void> fetchExchangeRate() async {
    final String apiKey = dotenv.env['EXCHANGE_RATE_API_KEY'] ?? emptyString;

    final http.Response response = await http.get(
      Uri.parse(
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/USD',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        exchangeRate = data['conversion_rates']['HNL'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load exchange rate');
    }
  }
}

FinancialData getFinancialData() {
  return FinancialData(
    totalExpensesLempiras: 3000,
    totalExpensesDollars: 200,
    totalIncomesLempiras: 10000,
    totalIncomesDollars: 300,
  );
}
