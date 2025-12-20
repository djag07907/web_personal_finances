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
import 'package:web_personal_finances/resources/api_constants.dart';
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
    // fetchExchangeRate();
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
                        '$dollarValue ${exchangeRate?.toStringAsFixed(2)} $hnlCurrency',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
            welcomeMessage,
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
        _buildCustomCardItems(),
        SizedBox(height: 10),
        ExpenseToIncomeBar(
          totalIncomes: financialData.totalIncomesLempiras.toDouble(),
          totalExpenses: financialData.totalExpensesLempiras.toDouble(),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: _buildPieChart(financialData)),
            SizedBox(width: 16),
            Expanded(child: _buildPieChart(financialData)),
          ],
        ),
        SizedBox(height: 10),
        _buildIndicators(financialData),
      ],
    );
  }

  Widget _buildCustomCardItems() {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isSmallScreen = screenWidth < 900;

        // For small screens, stack cards vertically or in 2 columns
        if (isSmallScreen) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CustomCardItem(
                    leadingIcon: Icons.attach_money,
                    titleText: context.translate('total_incomes'),
                    subtitleText: 'HNL 10,000',
                  ),
                  CustomCardItem(
                    leadingIcon: Icons.money_off,
                    titleText: context.translate('total_expenses'),
                    subtitleText: 'HNL 5,000',
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  CustomCardItem(
                    leadingIcon: Icons.pie_chart,
                    titleText: context.translate('savings'),
                    subtitleText: 'HNL 5,000',
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          );
        }

        // For larger screens, show in a single row
        return Row(
          children: <Widget>[
            CustomCardItem(
              leadingIcon: Icons.attach_money,
              titleText: context.translate('total_incomes'),
              subtitleText: 'HNL 10,000',
            ),
            CustomCardItem(
              leadingIcon: Icons.money_off,
              titleText: context.translate('total_expenses'),
              subtitleText: 'HNL 5,000',
            ),
            CustomCardItem(
              leadingIcon: Icons.pie_chart,
              titleText: context.translate('savings'),
              subtitleText: 'HNL 5,000',
            ),
          ],
        );
      },
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
          color: healthyGreen,
          text: 'Incomes: ${financialData.totalIncomes}',
          isSquare: true,
        ),
        SizedBox(height: 4),
        Indicator(
          color: unhealthyRed,
          text: 'Expenses: ${financialData.totalExpenses}',
          isSquare: true,
        ),
        SizedBox(height: 4),
        SizedBox(height: 18),
      ],
    );
  }

  List<PieChartSectionData> showingSections(final FinancialData financialData) {
    return List<PieChartSectionData>.generate(2, (final int i) {
      final bool isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25.0 : 16.0;
      final double radius = isTouched ? 60.0 : 50.0;
      const List<Shadow> shadows = <Shadow>[
        Shadow(color: black, blurRadius: 2),
      ];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: healthyGreen,
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
            color: unhealthyRed,
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
        '$apiRoute$apiKey$latestUsdRoute',
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

//TODO: Aqui se puede testear
FinancialData getFinancialData() {
  return FinancialData(
    totalExpensesLempiras: 3000,
    // totalExpensesDollars: 200,
    totalIncomesLempiras: 10000,
    // totalIncomesDollars: 300,
  );
}
