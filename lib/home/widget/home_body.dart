import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/accountsReceivable/model/account_receivable_item.dart';
import 'package:web_personal_finances/accountsToPay/model/account_to_pay_item.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/cards/kpi_info_tooltip.dart';
import 'package:web_personal_finances/commons/items/bill_item.dart';
import 'package:web_personal_finances/commons/items/transaction_item.dart';
import 'package:web_personal_finances/commons/layout/empty_content_widget.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/utils/account_to_pay_utils.dart';
import 'package:web_personal_finances/commons/utils/currency_kpi_utils.dart';
import 'package:web_personal_finances/expenses/model/expense_item.dart';
import 'package:web_personal_finances/home/bloc/home_bloc.dart';
import 'package:web_personal_finances/home/bloc/home_state.dart';
import 'package:web_personal_finances/home/model/category_breakdown_item.dart';
import 'package:web_personal_finances/home/widget/expense_income_bar.dart';
import 'package:web_personal_finances/incomes/model/income_item.dart';
import 'package:web_personal_finances/resources/api_constants.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/resources/fonts_constants.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

part 'dashboard_kpi_card.dart';
part 'expense_breakdown_card.dart';
part 'financial_breakdown_card.dart';
part 'income_sources_card.dart';
part 'recent_transactions_card.dart';
part 'upcoming_bills_card.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  double? exchangeRate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExchangeRate();
  }

  @override
  Widget build(final BuildContext context) {
    final HomeState homeState = context.watch<HomeBloc>().state;

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildHeader(context),
            Expanded(
              child: CustomCardBody(
                isMain: true,
                title: context.translate('home'),
                body: homeState is HomeLoaded
                    ? _buildDashboardContent(homeState)
                    : const Center(child: Loader()),
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

    final String welcomePrefix = context.translate('welcome_back');
    final String greeting = displayName.isNotEmpty
        ? '$welcomePrefix, $displayName'
        : welcomePrefix;

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(final HomeLoaded loadedState) {
    final UserModel profile = loadedState.profile;
    final List<IncomeItem> incomes = loadedState.incomes;
    final List<ExpenseItem> expenses = loadedState.expenses;
    final List<AccountToPayItem> accountsToPay = loadedState.accountsToPay;
    final List<AccountReceivableItem> accountsReceivable =
        loadedState.accountsReceivable;

    final String primaryCurrency = profile.primaryCurrency.isNotEmpty
        ? profile.primaryCurrency
        : hnlCurrency;

    // 1. Incomes cards (FIRST)
    final List<KpiCardSpec> incomeCards =
        CurrencyKpiUtils.generateIncomeKpiCards(
          incomeItems: incomes,
          user: profile,
          context: context,
        );

    // 2. Expenses cards (THEN)
    final List<KpiCardSpec> expenseCards =
        CurrencyKpiUtils.generateExpenseKpiCards(
          expenseItems: expenses,
          user: profile,
          context: context,
        );

    // 3. Accounts cards (THEN ACCOUNTS: to pay and receivable)
    final List<KpiCardSpec> payCards =
        CurrencyKpiUtils.generateAccountToPayKpiCards(
          items: accountsToPay,
          user: profile,
          context: context,
        );
    final List<KpiCardSpec> receivableCards =
        CurrencyKpiUtils.generateAccountReceivableKpiCards(
          items: accountsReceivable,
          user: profile,
          context: context,
        );

    // 4. Executive Overview & Net Cash Flow cards (ADDITIONAL CARDS)
    final List<KpiCardSpec> executiveCards = _generateExecutiveKpiCards(
      context: context,
      incomes: incomes,
      expenses: expenses,
      accountsToPay: accountsToPay,
      accountsReceivable: accountsReceivable,
      user: profile,
    );

    // Monthly values for ExpenseToIncomeBar
    final double projectedIncomePrimary =
        CurrencyKpiUtils.calculateMonthlyProjectedIncome(
          items: incomes,
          currency: primaryCurrency,
        );
    final double burnRatePrimary = CurrencyKpiUtils.calculateMonthlyBurnRate(
      items: expenses,
      currency: primaryCurrency,
    );

    // Dynamic Category Breakdowns for the Financial Distribution Tab Card
    final List<CategoryBreakdownItem> expenseCategoryItems =
        _computeExpenseBreakdown(expenses, primaryCurrency, context);
    final List<CategoryBreakdownItem> incomeCategoryItems =
        _computeIncomeBreakdown(incomes, primaryCurrency, context);

    final double totalExpensesForCurrency = expenses
        .where(
          (final ExpenseItem e) => e.status && e.currency == primaryCurrency,
        )
        .fold(0.0, (final double sum, final ExpenseItem e) => sum + e.amount);

    final double totalIncomesForCurrency = incomes
        .where(
          (final IncomeItem i) => i.status && i.currency == primaryCurrency,
        )
        .fold(0.0, (final double sum, final IncomeItem i) => sum + i.amount);

    final List<TransactionItem> transactions = _buildTransactionItems(
      incomes,
      expenses,
    );
    final List<BillItem> bills = _buildBillItems(accountsToPay, context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. TOP CASH FLOW HEALTH GAUGE (Prominent on top)
          ExpenseToIncomeBar(
            totalIncomes: projectedIncomePrimary,
            totalExpenses: burnRatePrimary,
            currency: primaryCurrency,
          ),
          const SizedBox(height: 18),

          // 2. EXECUTIVE TWO-COLUMN / DESKTOP LAYOUT
          LayoutBuilder(
            builder: (final BuildContext context, final BoxConstraints constraints) {
              final bool isWideScreen = constraints.maxWidth >= 1150;

              final Widget mainContentColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Section 1: Incomes (FIRST)
                  _buildSectionHeader(
                    context: context,
                    title: context.translate('incomes'),
                    subtitle: context.translate('incomes_section_subtitle'),
                    icon: Icons.trending_up,
                    iconColor: LightColors.primary,
                    count: incomes
                        .where((final IncomeItem i) => i.status)
                        .length,
                  ),
                  _buildKpiGrid(incomeCards),

                  // Section 2: Expenses (THEN)
                  _buildSectionHeader(
                    context: context,
                    title: context.translate('expenses'),
                    subtitle: context.translate('expenses_section_subtitle'),
                    icon: Icons.trending_down,
                    iconColor: Colors.orange[700] ?? Colors.orange,
                    count: expenses
                        .where((final ExpenseItem e) => e.status)
                        .length,
                  ),
                  _buildKpiGrid(expenseCards),

                  // Section 3: Accounts to Pay (THEN ACCOUNTS)
                  _buildSectionHeader(
                    context: context,
                    title: context.translate('accounts_to_pay'),
                    subtitle: context.translate(
                      'accounts_to_pay_section_subtitle',
                    ),
                    icon: Icons.receipt_long_outlined,
                    iconColor: Colors.amber[700] ?? Colors.amber,
                    count: accountsToPay
                        .where(
                          (final AccountToPayItem a) =>
                              a.status && !a.isFullyPaid,
                        )
                        .length,
                  ),
                  _buildKpiGrid(payCards),

                  // Section 4: Accounts Receivable (AND RECEIVABLE)
                  _buildSectionHeader(
                    context: context,
                    title: context.translate('accounts_receivable'),
                    subtitle: context.translate(
                      'accounts_receivable_section_subtitle',
                    ),
                    icon: Icons.call_received_outlined,
                    iconColor: Colors.teal[600] ?? Colors.teal,
                    count: accountsReceivable
                        .where(
                          (final AccountReceivableItem a) =>
                              a.status && !a.isFullyPaid,
                        )
                        .length,
                  ),
                  _buildKpiGrid(receivableCards),

                  // Section 5: Executive Financial Health & Cash Flow (ADDITIONAL CARDS)
                  _buildSectionHeader(
                    context: context,
                    title: context.translate('executive_cash_flow_title'),
                    subtitle: context.translate('executive_cash_flow_subtitle'),
                    icon: Icons.balance_outlined,
                    iconColor: LightColors.primary,
                  ),
                  _buildKpiGrid(executiveCards),

                  const SizedBox(height: 20),
                  // Section 6: Unified Financial Distribution Tab Card (Expenses vs Incomes)
                  FinancialBreakdownCard(
                    expenseItems: expenseCategoryItems,
                    incomeItems: incomeCategoryItems,
                    totalExpenses: totalExpensesForCurrency,
                    totalIncomes: totalIncomesForCurrency,
                    currency: primaryCurrency,
                  ),
                ],
              );

              final Widget sidebarColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  UpcomingBillsCard(bills: bills, onAddBill: () {}),
                  const SizedBox(height: 18),
                  RecentTransactionsCard(
                    transactions: transactions,
                    onViewAll: () {},
                  ),
                ],
              );

              if (isWideScreen) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: mainContentColumn),
                    const SizedBox(width: 20),
                    SizedBox(width: 370, child: sidebarColumn),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  mainContentColumn,
                  const SizedBox(height: 24),
                  sidebarColumn,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required final BuildContext context,
    required final String title,
    final String? subtitle,
    required final IconData icon,
    required final Color iconColor,
    final int? count,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (count != null) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DarkColors.surfaceLight
                                : LightColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(final List<KpiCardSpec> cards) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount;
        if (width < 480) {
          crossAxisCount = 1;
        } else if (width < 800) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = cards.length >= 4 ? 4 : (cards.length >= 3 ? 3 : 2);
        }

        final double totalSpacing = 10.0 * (crossAxisCount - 1);
        final double cardWidth = (width - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: cards.map((final KpiCardSpec spec) {
            return SizedBox(
              width: cardWidth.clamp(190.0, double.infinity),
              child: DashboardKpiCard(spec: spec),
            );
          }).toList(),
        );
      },
    );
  }

  List<KpiCardSpec> _generateExecutiveKpiCards({
    required final BuildContext context,
    required final List<IncomeItem> incomes,
    required final List<ExpenseItem> expenses,
    required final List<AccountToPayItem> accountsToPay,
    required final List<AccountReceivableItem> accountsReceivable,
    required final UserModel? user,
  }) {
    final bool isDual = user?.enableDualCurrency ?? false;
    final String primary =
        (user?.primaryCurrency != null && user!.primaryCurrency.isNotEmpty)
        ? user.primaryCurrency
        : hnlCurrency;
    final String secondary = primary == hnlCurrency ? usdCurrency : hnlCurrency;
    final List<String> currencies = <String>[primary, if (isDual) secondary];

    final List<KpiCardSpec> cards = <KpiCardSpec>[];

    for (final String currency in currencies) {
      final double projectedIncome =
          CurrencyKpiUtils.calculateMonthlyProjectedIncome(
            items: incomes,
            currency: currency,
          );
      final double burnRate = CurrencyKpiUtils.calculateMonthlyBurnRate(
        items: expenses,
        currency: currency,
      );
      final double netMonthlyCashFlow = projectedIncome - burnRate;

      final double pendingPayables = accountsToPay
          .where(
            (final AccountToPayItem a) =>
                a.status && !a.isFullyPaid && a.currency == currency,
          )
          .fold(
            0.0,
            (final double sum, final AccountToPayItem a) =>
                sum + a.remainingBalance,
          );

      final double pendingReceivables = accountsReceivable
          .where(
            (final AccountReceivableItem a) =>
                a.status && !a.isFullyPaid && a.currency == currency,
          )
          .fold(
            0.0,
            (final double sum, final AccountReceivableItem a) =>
                sum + a.remainingBalance,
          );

      final double netDebtBalance = pendingReceivables - pendingPayables;
      final double margin = projectedIncome > 0
          ? (netMonthlyCashFlow / projectedIncome) * 100
          : 0.0;

      String suffix(final String label) =>
          isDual ? '$label ($currency)' : label;

      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('net_monthly_cash_flow')),
          amount: CurrencyKpiUtils.formatAmount(netMonthlyCashFlow, currency),
          subtitle: netMonthlyCashFlow >= 0
              ? context.translate('monthly_operating_surplus')
              : context.translate('monthly_cash_deficit'),
          isPositive: netMonthlyCashFlow >= 0,
          icon: netMonthlyCashFlow >= 0
              ? Icons.savings_outlined
              : Icons.warning_amber_rounded,
          currency: currency,
          description: context.translate('net_monthly_cash_flow_desc'),
          calculation: context.translate('net_monthly_cash_flow_calc'),
        ),
      );

      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('cash_flow_margin')),
          amount: '${margin.toStringAsFixed(1)}%',
          subtitle: margin >= 20
              ? context.translate('strong_savings_capacity')
              : (margin >= 0
                    ? context.translate('moderate_margin')
                    : context.translate('deficit_burn')),
          isPositive: margin >= 0,
          icon: Icons.pie_chart_outline,
          currency: currency,
          description: context.translate('cash_flow_margin_desc'),
          calculation: context.translate('cash_flow_margin_calc'),
        ),
      );

      cards.add(
        KpiCardSpec(
          title: suffix(context.translate('net_outstanding_position')),
          amount: CurrencyKpiUtils.formatAmount(netDebtBalance.abs(), currency),
          subtitle: netDebtBalance >= 0
              ? context.translate('receivables_exceed_liabilities')
              : context.translate('liabilities_exceed_receivables'),
          isPositive: netDebtBalance >= 0,
          icon: Icons.balance_outlined,
          currency: currency,
          description: context.translate('net_outstanding_position_desc'),
          calculation: context.translate('net_outstanding_position_calc'),
        ),
      );
    }

    return cards;
  }

  List<CategoryBreakdownItem> _computeExpenseBreakdown(
    final List<ExpenseItem> expenses,
    final String currency,
    final BuildContext context,
  ) {
    final List<ExpenseItem> active = expenses
        .where((final ExpenseItem e) => e.status && e.currency == currency)
        .toList();
    if (active.isEmpty) {
      return <CategoryBreakdownItem>[];
    }

    final Map<String, double> categorySums = <String, double>{};
    double total = 0.0;
    for (final ExpenseItem item in active) {
      final String catName = item.category.toTranslate(context);
      categorySums[catName] = (categorySums[catName] ?? 0.0) + item.amount;
      total += item.amount;
    }

    if (total == 0) {
      return <CategoryBreakdownItem>[];
    }

    final List<Color> palette = <Color>[
      const Color(0xFFEF4444), // Red
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF97316), // Orange
    ];

    final List<MapEntry<String, double>> sorted = categorySums.entries.toList()
      ..sort(
        (final MapEntry<String, double> a, final MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );

    final List<CategoryBreakdownItem> result = <CategoryBreakdownItem>[];
    for (int i = 0; i < sorted.length; i++) {
      final MapEntry<String, double> entry = sorted[i];
      result.add(
        CategoryBreakdownItem(
          categoryName: entry.key,
          amount: entry.value,
          percentage: (entry.value / total) * 100.0,
          color: palette[i % palette.length],
        ),
      );
    }
    return result;
  }

  List<CategoryBreakdownItem> _computeIncomeBreakdown(
    final List<IncomeItem> incomes,
    final String currency,
    final BuildContext context,
  ) {
    final List<IncomeItem> active = incomes
        .where((final IncomeItem i) => i.status && i.currency == currency)
        .toList();
    if (active.isEmpty) {
      return <CategoryBreakdownItem>[];
    }

    final Map<String, double> categorySums = <String, double>{};
    double total = 0.0;
    for (final IncomeItem item in active) {
      final String catName = item.category.toTranslate(context);
      categorySums[catName] = (categorySums[catName] ?? 0.0) + item.amount;
      total += item.amount;
    }

    if (total == 0) {
      return <CategoryBreakdownItem>[];
    }

    final List<Color> palette = <Color>[
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF14B8A6), // Teal
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF84CC16), // Lime
    ];

    final List<MapEntry<String, double>> sorted = categorySums.entries.toList()
      ..sort(
        (final MapEntry<String, double> a, final MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );

    final List<CategoryBreakdownItem> result = <CategoryBreakdownItem>[];
    for (int i = 0; i < sorted.length; i++) {
      final MapEntry<String, double> entry = sorted[i];
      result.add(
        CategoryBreakdownItem(
          categoryName: entry.key,
          amount: entry.value,
          percentage: (entry.value / total) * 100.0,
          color: palette[i % palette.length],
        ),
      );
    }
    return result;
  }

  List<TransactionItem> _buildTransactionItems(
    final List<IncomeItem> incomes,
    final List<ExpenseItem> expenses,
  ) {
    final List<TransactionItem> transactions = <TransactionItem>[];
    for (final IncomeItem income in incomes) {
      transactions.add(
        TransactionItem(
          title: income.name,
          category: income.category.toTranslate(context),
          date: income.dateToReceive,
          amount: income.amount,
          isIncome: true,
          icon: Icons.payments_outlined,
          iconColor: LightColors.primary,
        ),
      );
    }
    for (final ExpenseItem expense in expenses) {
      transactions.add(
        TransactionItem(
          title: expense.name,
          category: expense.category.toTranslate(context),
          date: expense.dateDue,
          amount: expense.amount,
          isIncome: false,
          icon: Icons.shopping_bag_outlined,
          iconColor: Colors.orange[700] ?? Colors.orange,
        ),
      );
    }
    return transactions;
  }

  List<BillItem> _buildBillItems(
    final List<AccountToPayItem> accountsToPay,
    final BuildContext context,
  ) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final List<BillItem> bills = <BillItem>[];
    for (final AccountToPayItem item in accountsToPay.where(
      (final AccountToPayItem a) => a.status && !a.isFullyPaid,
    )) {
      final DateTime nextDue = AccountToPayUtils.getNextDueDate(item);
      final String dueMonth = DateFormat('MMM', languageCode).format(nextDue);
      final String dueDate = nextDue.day.toString().padLeft(2, '0');
      final bool isPastDue = AccountToPayUtils.isOverdue(item);
      bills.add(
        BillItem(
          title: item.creditorName,
          provider: item.description.isNotEmpty
              ? item.description
              : context.translate('account_to_pay_fallback'),
          dueDate: dueDate,
          dueMonth: dueMonth,
          amount: (item.monthlyQuota != null && item.monthlyQuota! > 0)
              ? item.monthlyQuota!
              : item.remainingBalance,
          isPastDue: isPastDue,
        ),
      );
    }
    return bills;
  }

  Future<void> fetchExchangeRate() async {
    final String apiKey = dotenv.env['EXCHANGE_RATE_API_KEY'] ?? emptyString;

    try {
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
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
