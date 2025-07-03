import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/accountsReceivable/accounts_receivable_screen.dart';
import 'package:web_personal_finances/accountsToPay/accounts_to_pay_screen.dart';
import 'package:web_personal_finances/expenses/expenses_screen.dart';
import 'package:web_personal_finances/home/home_screen.dart';
import 'package:web_personal_finances/incomes/incomes_screen.dart';
import 'package:web_personal_finances/login/login_screen.dart';
import 'package:web_personal_finances/menu/menu_screen.dart';
import 'package:web_personal_finances/profile/profile_screen.dart';
import 'package:web_personal_finances/savings/savings_screen.dart';
import 'package:web_personal_finances/signUp/signup_screen.dart';

part 'landing_constants.dart';

final GoRouter appRoutes = GoRouter(
  initialLocation: rootRoute,
  routes: <RouteBase>[
    GoRoute(
      path: rootRoute,
      redirect: (final BuildContext context, final GoRouterState state) =>
          loginRoute,
    ),
    GoRoute(
      path: loginRoute,
      builder: (final BuildContext context, final GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: signupRoute,
      builder: (final BuildContext context, final GoRouterState state) {
        return const SignUpScreen();
      },
    ),
    ShellRoute(
      builder: (
        final BuildContext context,
        final GoRouterState state,
        final Widget child,
      ) {
        return MenuScreen(
          menuBody: child,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: homeRoute,
          builder: (final BuildContext context, final GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: incomesRoute,
          builder: (final BuildContext context, final GoRouterState state) {
            return const IncomesScreen();
          },
        ),
        GoRoute(
          path: expensesRoute,
          builder: (final BuildContext context, final GoRouterState state) {
            return const ExpensesScreen();
          },
        ),
        GoRoute(
          path: accountsToPayRoute,
          builder: (final BuildContext context, final GoRouterState state) {
            return const AccountsToPayScreen();
          },
        ),
        GoRoute(
          path: accountsReceivableRoute,
          builder: (final BuildContext context, final GoRouterState state) {
            return const AccountsReceivableScreen();
          },
        ),
        GoRoute(
          path: savingsRoute,
          builder: (final BuildContext context, final GoRouterState state) {
            return const SavingsScreen();
          },
        ),
        GoRoute(
          path: profileRoute,
          builder: (final BuildContext context, final GoRouterState state) {
            return const ProfileScreen();
          },
        ),
      ],
    ),
  ],
);
