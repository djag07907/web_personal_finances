import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/accountsReceivable/accounts_receivable_screen.dart';
import 'package:web_personal_finances/accountsToPay/accounts_to_pay_screen.dart';
import 'package:web_personal_finances/commons/bloc/app_auth_notifier.dart';
import 'package:web_personal_finances/commons/utils/navigation_utils.dart';
import 'package:web_personal_finances/expenses/expenses_screen.dart';
import 'package:web_personal_finances/home/home_screen.dart';
import 'package:web_personal_finances/incomes/incomes_screen.dart';
import 'package:web_personal_finances/login/login_screen.dart';
import 'package:web_personal_finances/menu/menu_screen.dart';
import 'package:web_personal_finances/onboarding/onboarding_screen.dart';
import 'package:web_personal_finances/profile/profile_screen.dart';
import 'package:web_personal_finances/savings/savings_screen.dart';
import 'package:web_personal_finances/signUp/signup_screen.dart';

part 'landing_constants.dart';

/// Routes that are only accessible to unauthenticated users.
const Set<String> _publicRoutes = <String>{rootRoute, loginRoute, signupRoute};

/// Routes that require authentication but do NOT require completed onboarding.
const Set<String> _semiPublicRoutes = <String>{onboardingRoute};

GoRouter buildAppRouter(final AppAuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: rootRoute,
    refreshListenable: authNotifier,
    redirect: (final BuildContext context, final GoRouterState state) {
      // While the initial auth check is still pending, stay put.
      if (authNotifier.isLoading) return null;

      final bool isAuthenticated = authNotifier.isAuthenticated;
      final bool isOnboarded = authNotifier.isOnboarded;
      final String location = state.matchedLocation;

      // ── Unauthenticated ───────────────────────────────────────────────────
      if (!isAuthenticated) {
        // Allow public pages; redirect everything else to login.
        return _publicRoutes.contains(location) ? null : loginRoute;
      }

      // ── Authenticated but NOT onboarded ───────────────────────────────────
      if (!isOnboarded) {
        // Only allow the onboarding route; push everything else there.
        return _semiPublicRoutes.contains(location) ? null : onboardingRoute;
      }

      // ── Authenticated AND onboarded ───────────────────────────────────────
      // Redirect away from auth/onboarding pages to the home screen.
      if (_publicRoutes.contains(location) ||
          _semiPublicRoutes.contains(location)) {
        return homeRoute;
      }

      // Everything else is fine.
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: rootRoute,
        redirect: (final BuildContext context, final GoRouterState state) =>
            loginRoute,
      ),
      GoRoute(
        path: loginRoute,
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            snappyTransitionPage(
              key: state.pageKey,
              child: const LoginScreen(),
            ),
      ),
      GoRoute(
        path: signupRoute,
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            snappyTransitionPage(
              key: state.pageKey,
              child: const SignUpScreen(),
            ),
      ),
      GoRoute(
        path: onboardingRoute,
        pageBuilder: (final BuildContext context, final GoRouterState state) =>
            snappyTransitionPage(
              key: state.pageKey,
              child: const OnboardingScreen(),
            ),
      ),
      ShellRoute(
        builder:
            (
              final BuildContext context,
              final GoRouterState state,
              final Widget child,
            ) {
              return MenuScreen(menuBody: child);
            },
        routes: <RouteBase>[
          GoRoute(
            path: homeRoute,
            pageBuilder:
                (final BuildContext context, final GoRouterState state) =>
                    snappyTransitionPage(
                      key: state.pageKey,
                      child: const HomeScreen(),
                    ),
          ),
          GoRoute(
            path: incomesRoute,
            pageBuilder:
                (final BuildContext context, final GoRouterState state) =>
                    snappyTransitionPage(
                      key: state.pageKey,
                      child: const IncomesScreen(),
                    ),
          ),
          GoRoute(
            path: expensesRoute,
            pageBuilder:
                (final BuildContext context, final GoRouterState state) =>
                    snappyTransitionPage(
                      key: state.pageKey,
                      child: const ExpensesScreen(),
                    ),
          ),
          GoRoute(
            path: accountsToPayRoute,
            pageBuilder:
                (final BuildContext context, final GoRouterState state) =>
                    snappyTransitionPage(
                      key: state.pageKey,
                      child: const AccountsToPayScreen(),
                    ),
          ),
          GoRoute(
            path: accountsReceivableRoute,
            pageBuilder:
                (final BuildContext context, final GoRouterState state) =>
                    snappyTransitionPage(
                      key: state.pageKey,
                      child: const AccountsReceivableScreen(),
                    ),
          ),
          GoRoute(
            path: savingsRoute,
            pageBuilder:
                (final BuildContext context, final GoRouterState state) =>
                    snappyTransitionPage(
                      key: state.pageKey,
                      child: const SavingsScreen(),
                    ),
          ),
          GoRoute(
            path: profileRoute,
            pageBuilder:
                (final BuildContext context, final GoRouterState state) =>
                    snappyTransitionPage(
                      key: state.pageKey,
                      child: const ProfileScreen(),
                    ),
          ),
        ],
      ),
    ],
  );
}
