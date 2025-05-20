import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/home/home_screen.dart';
import 'package:web_personal_finances/login/login_screen.dart';

part 'landing_constants.dart';

final GoRouter appRoutes = GoRouter(
  initialLocation: loginRoute,
  routes: <RouteBase>[
    GoRoute(
      path: loginRoute,
      builder: (final BuildContext context, final GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: homeRoute,
      builder: (final BuildContext context, final GoRouterState state) {
        return const HomeScreen();
      },
    ),
  ],
);
