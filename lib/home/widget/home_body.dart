import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/cards/custom_card_item.dart';
import 'package:web_personal_finances/commons/items/bill_item.dart';
import 'package:web_personal_finances/commons/items/transaction_item.dart';
import 'package:web_personal_finances/home/model/financial_data.dart';
import 'package:web_personal_finances/home/widget/expense_income_bar.dart';
import 'package:web_personal_finances/resources/api_constants.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';

part 'expense_breakdown_card.dart';
part 'income_sources_card.dart';
part 'recent_transactions_card.dart';
part 'upcoming_bills_card.dart';

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildCustomCardItems(),
            SizedBox(height: 24),
            ExpenseToIncomeBar(
              totalIncomes: financialData.totalIncomesLempiras.toDouble(),
              totalExpenses: financialData.totalExpensesLempiras.toDouble(),
            ),
            SizedBox(height: 24),
            _buildChartsSection(),
            SizedBox(height: 24),
            _buildTransactionsAndBillsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isSmallScreen = screenWidth < 900;

        if (isSmallScreen) {
          return Column(
            children: <Widget>[
              SizedBox(
                height: 320,
                child: ExpenseBreakdownCard(
                  expenseData: <String, double>{
                    'Housing': 45.0,
                    'Food': 25.0,
                    'Others': 30.0,
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 320,
                child: IncomeSourcesCard(
                  incomeData: <String, double>{
                    'Salary': 60.0,
                    'Freelance': 25.0,
                    'Invest': 15.0,
                  },
                  totalIncome: 5240.0,
                ),
              ),
            ],
          );
        }

        return SizedBox(
          height: 320,
          child: Row(
            children: <Widget>[
              Expanded(
                child: ExpenseBreakdownCard(
                  expenseData: <String, double>{
                    'Housing': 45.0,
                    'Food': 25.0,
                    'Others': 30.0,
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: IncomeSourcesCard(
                  incomeData: <String, double>{
                    'Salary': 60.0,
                    'Freelance': 25.0,
                    'Invest': 15.0,
                  },
                  totalIncome: 5240.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsAndBillsSection() {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isSmallScreen = screenWidth < 900;

        if (isSmallScreen) {
          return Column(
            children: <Widget>[
              SizedBox(
                height: 400,
                child: RecentTransactionsCard(
                  transactions: _getSampleTransactions(),
                  onViewAll: () {
                    // TODO: Navigate to transactions page
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: UpcomingBillsCard(
                  bills: _getSampleBills(),
                  onAddBill: () {
                    // TODO: Show add bill dialog
                  },
                ),
              ),
            ],
          );
        }

        return SizedBox(
          height: 450,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: RecentTransactionsCard(
                  transactions: _getSampleTransactions(),
                  onViewAll: () {
                    // TODO: Navigate to transactions page
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: UpcomingBillsCard(
                  bills: _getSampleBills(),
                  onAddBill: () {
                    // TODO: Show add bill dialog
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<TransactionItem> _getSampleTransactions() {
    return <TransactionItem>[
      TransactionItem(
        title: 'Netflix Subscription',
        category: 'Entertainment',
        date: 'Today',
        amount: 15.99,
        isIncome: false,
        icon: Icons.movie,
        iconColor: Colors.red[600]!,
      ),
      TransactionItem(
        title: 'Whole Foods Market',
        category: 'Groceries',
        date: 'Yesterday',
        amount: 124.50,
        isIncome: false,
        icon: Icons.shopping_cart,
        iconColor: Colors.green[600]!,
      ),
      TransactionItem(
        title: 'Upwork Earnings',
        category: 'Income',
        date: 'Mar 20',
        amount: 850.00,
        isIncome: true,
        icon: Icons.work,
        iconColor: Colors.blue[600]!,
      ),
      TransactionItem(
        title: 'Downtown Diner',
        category: 'Food',
        date: 'Mar 18',
        amount: 42.80,
        isIncome: false,
        icon: Icons.restaurant,
        iconColor: Colors.orange[600]!,
      ),
    ];
  }

  List<BillItem> _getSampleBills() {
    return <BillItem>[
      BillItem(
        title: 'Electric Bill',
        provider: 'Utility Company',
        dueDate: '28',
        dueMonth: 'Mar',
        amount: 85.00,
      ),
      BillItem(
        title: 'Apartment Rent',
        provider: 'Monthly',
        dueDate: '01',
        dueMonth: 'Apr',
        amount: 1200.00,
      ),
    ];
  }

  Widget _buildCustomCardItems() {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isSmallScreen = screenWidth < 900;

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
