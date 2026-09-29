import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/cards/custom_card_item.dart';
import 'package:web_personal_finances/commons/items/bill_item.dart';
import 'package:web_personal_finances/commons/items/transaction_item.dart';
import 'package:web_personal_finances/commons/layout/empty_content_widget.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/home/bloc/home_bloc.dart';
import 'package:web_personal_finances/home/bloc/home_state.dart';
import 'package:web_personal_finances/home/model/financial_data.dart';
import 'package:web_personal_finances/home/widget/expense_income_bar.dart';
import 'package:web_personal_finances/resources/api_constants.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

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
    final HomeState homeState = context.watch<HomeBloc>().state;
    final UserModel? profile = homeState is HomeLoaded
        ? homeState.profile
        : null;

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildHeader(context),
            Expanded(
              child: CustomCardBody(
                isMain: true,
                title: context.translate('home'),
                body: _buildCharts(financialData, profile),
              ),
            ),
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  '$dollarValue ${exchangeRate?.toStringAsFixed(2)} $hnlCurrency',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? DarkColors.textPrimary
                        : null,
                  ),
                ),
              ),
          ],
        ),
        if (isLoading || homeState is HomeLoading) const Loader(),
      ],
    );
  }

  Widget _buildHeader(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final HomeState homeState = context.watch<HomeBloc>().state;
    final String displayName = homeState is HomeLoaded
        ? (homeState.profile.fullName.isNotEmpty
              ? homeState.profile.fullName
              : homeState.profile.email)
        : emptyString;

    final String greeting = displayName.isNotEmpty
        ? 'Welcome back, $displayName'
        : 'Welcome back';

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        height: 50.0,
        margin: const EdgeInsets.only(top: 10.0),
        width: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
          color: isDark ? DarkColors.primary : LightColors.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(300.0),
            bottomLeft: Radius.circular(300.0),
          ),
          boxShadow: isDark
              ? <BoxShadow>[
                  BoxShadow(
                    color: DarkColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            greeting,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: fontSize24,
              color: white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharts(
    final FinancialData financialData,
    final UserModel? profile,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildCustomCardItems(profile),
            const SizedBox(height: 24),
            ExpenseToIncomeBar(
              totalIncomes: financialData.totalIncomesLempiras.toDouble(),
              totalExpenses: financialData.totalExpensesLempiras.toDouble(),
            ),
            const SizedBox(height: 24),
            _buildChartsSection(profile),
            const SizedBox(height: 24),
            _buildTransactionsAndBillsSection(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(final UserModel? profile) {
    // No real data yet → show empty state.
    final bool hasNoData = profile == null;

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isSmallScreen = screenWidth < 900;

        if (hasNoData) {
          return SizedBox(
            height: 320,
            child: EmptyContentWidget(
              icon: Icons.bar_chart_rounded,
              title: 'No chart data yet',
              subtitle:
                  'Start recording your incomes and expenses to see your financial breakdown here.',
            ),
          );
        }

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
              const SizedBox(height: 16),
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
              const SizedBox(width: 16),
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

  Widget _buildTransactionsAndBillsSection(final UserModel? profile) {
    final bool hasNoData = profile == null;

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isSmallScreen = screenWidth < 900;

        if (hasNoData) {
          return SizedBox(
            height: 280,
            child: EmptyContentWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              subtitle:
                  'Your recent transactions and upcoming bills will appear here once you start recording.',
            ),
          );
        }

        if (isSmallScreen) {
          return Column(
            children: <Widget>[
              SizedBox(
                height: 400,
                child: RecentTransactionsCard(
                  transactions: _getSampleTransactions(),
                  onViewAll: () {},
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: UpcomingBillsCard(
                  bills: _getSampleBills(),
                  onAddBill: () {},
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
                  onViewAll: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: UpcomingBillsCard(
                  bills: _getSampleBills(),
                  onAddBill: () {},
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

  Widget _buildCustomCardItems(final UserModel? profile) {
    final bool hasNoData = profile == null;

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isSmallScreen = screenWidth < 900;

        final String currencyLabel = profile?.primaryCurrency ?? hnlCurrency;

        final String incomesLabel = hasNoData ? '--' : '$currencyLabel 10,000';
        final String expensesLabel = hasNoData ? '--' : '$currencyLabel 5,000';
        final String savingsLabel = hasNoData ? '--' : '$currencyLabel 5,000';

        if (isSmallScreen) {
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CustomCardItem(
                    leadingIcon: Icons.attach_money,
                    titleText: context.translate('total_incomes'),
                    subtitleText: incomesLabel,
                  ),
                  CustomCardItem(
                    leadingIcon: Icons.money_off,
                    titleText: context.translate('total_expenses'),
                    subtitleText: expensesLabel,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  CustomCardItem(
                    leadingIcon: Icons.pie_chart,
                    titleText: context.translate('savings'),
                    subtitleText: savingsLabel,
                  ),
                  const Flexible(fit: FlexFit.tight, child: SizedBox.shrink()),
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
              subtitleText: incomesLabel,
            ),
            CustomCardItem(
              leadingIcon: Icons.money_off,
              titleText: context.translate('total_expenses'),
              subtitleText: expensesLabel,
            ),
            CustomCardItem(
              leadingIcon: Icons.pie_chart,
              titleText: context.translate('savings'),
              subtitleText: savingsLabel,
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchExchangeRate() async {
    final String apiKey = dotenv.env['EXCHANGE_RATE_API_KEY'] ?? emptyString;

    final http.Response response = await http.get(
      Uri.parse('$apiRoute$apiKey$latestUsdRoute'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
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
