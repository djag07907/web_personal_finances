import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A premium, lightweight page transition utility that provides an ease-out
/// cubic fade animation for GoRouter routes to maintain a top-performance,
/// modern single-page application feel.
Page<dynamic> snappyTransitionPage({
  required final LocalKey key,
  required final Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: RepaintBoundary(child: child),
    transitionsBuilder:
        (
          final BuildContext context,
          final Animation<double> animation,
          final Animation<double> secondaryAnimation,
          final Widget child,
        ) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
            child: child,
          );
        },
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 150),
  );
}
