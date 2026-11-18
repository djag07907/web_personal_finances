import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

/// A pure-Flutter animated hero showcase widget tailored specifically for
/// new users starting their financial journey — focusing on milestone goals,
/// initial emergency savings, and cashflow budgeting.
class SignupHeroWidget extends StatefulWidget {
  const SignupHeroWidget({super.key, required this.isDark});

  final bool isDark;

  @override
  State<SignupHeroWidget> createState() => _SignupHeroWidgetState();
}

class _SignupHeroWidgetState extends State<SignupHeroWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (final BuildContext context, final Widget? child) {
          final double t = _animationController.value;
          final double cardFloat = math.sin(t * 2 * math.pi) * 5.0;
          final double chip1Float = math.cos(t * 2 * math.pi) * 4.0;
          final double chip2Float =
              math.sin((t * 2 * math.pi) + (math.pi / 2)) * 4.0;
          final double pulse = (math.sin(t * 4 * math.pi) + 1.0) / 2.0;
          final double progress = 0.80 + (0.03 * math.sin(t * 2 * math.pi));

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Visual Animation Container (Scales down gracefully on narrow desktop splits)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 380,
                  height: 290,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Ambient radial glow
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: <Color>[
                                LightColors.primary.withValues(
                                  alpha: widget.isDark ? 0.16 : 0.12,
                                ),
                                transparent,
                              ],
                              radius: 0.65,
                            ),
                          ),
                        ),
                      ),

                      // Main Floating Milestone & Savings Card
                      Transform.translate(
                        offset: Offset(0, cardFloat),
                        child: Container(
                          width: 315,
                          padding: const EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? const Color(0xFF141F1B)
                                : white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.isDark
                                  ? const Color(0xFF263830)
                                  : LightColors.primary.withValues(alpha: 0.20),
                              width: 1.5,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: widget.isDark
                                    ? black.withValues(alpha: 0.45)
                                    : LightColors.primary.withValues(
                                        alpha: 0.10,
                                      ),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Header: Savings Icon, Milestone Title, and Progress Pill
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: LightColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.savings_rounded,
                                      size: 20,
                                      color: LightColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          context.translate(
                                            'signup_hero_goal_title',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: widget.isDark
                                                ? DarkColors.textSecondary
                                                : LightColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          context.translate(
                                            'signup_hero_goal_target',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.3,
                                            color: widget.isDark
                                                ? white
                                                : LightColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Milestone percentage pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: LightColors.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.flag_rounded,
                                          size: 11,
                                          color: LightColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          context.translate(
                                            'signup_hero_progress_label',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: LightColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Dynamic Milestone Progress Bar
                              SizedBox(
                                height: 10,
                                width: double.infinity,
                                child: Stack(
                                  children: <Widget>[
                                    // Background track
                                    Container(
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? const Color(0xFF22332B)
                                            : LightColors.surface,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    // Active animated progress fill
                                    LayoutBuilder(
                                      builder:
                                          (
                                            final BuildContext context,
                                            final BoxConstraints constraints,
                                          ) {
                                            final double fillWidth =
                                                constraints.maxWidth * progress;
                                            return Stack(
                                              children: <Widget>[
                                                Container(
                                                  width: fillWidth,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: <Color>[
                                                            LightColors.primary,
                                                            healthyGreen,
                                                          ],
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                // Gliding beacon dot at the tip of progress
                                                Positioned(
                                                  left: math.max(
                                                    0,
                                                    fillWidth - 8,
                                                  ),
                                                  top: 1,
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: white,
                                                      boxShadow: <BoxShadow>[
                                                        BoxShadow(
                                                          color: LightColors
                                                              .primary
                                                              .withValues(
                                                                alpha:
                                                                    0.5 +
                                                                    (0.5 *
                                                                        pulse),
                                                              ),
                                                          blurRadius: 6,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Cashflow Inflow vs Outflow Mini-Dashboard (Responsive 2-tier layout)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.isDark
                                      ? const Color(0xFF1B2822)
                                      : const Color(0xFFF3F7F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: widget.isDark
                                        ? const Color(0xFF283B32)
                                        : LightColors.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    // Top Tier: Inflow and Outflow
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Icon(
                                                Icons.arrow_downward_rounded,
                                                size: 13,
                                                color: healthyGreen,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  context.translate(
                                                    'signup_hero_income',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: healthyGreen,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Icon(
                                                Icons.arrow_upward_rounded,
                                                size: 13,
                                                color: Color(0xFFE57373),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  context.translate(
                                                    'signup_hero_expenses',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFFE57373),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Bottom Tier: Net Surplus Saved
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: healthyGreen.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 11,
                                            color: healthyGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              context.translate(
                                                'signup_hero_saved',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: healthyGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Footer: Starting out steps
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 12,
                                          color: LightColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Budget Tracked',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: widget.isDark
                                                  ? DarkColors.textSecondary
                                                  : LightColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.shield_outlined,
                                          size: 12,
                                          color: LightColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Zero-Knowledge',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: widget.isDark
                                                  ? DarkColors.textSecondary
                                                  : LightColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top-Right Floating Chip: Smart Budget
                      Positioned(
                        top: 10,
                        right: 14,
                        child: Transform.translate(
                          offset: Offset(0, chip1Float),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? const Color(0xFF1B2C24)
                                  : white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: LightColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                width: 1.2,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: LightColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.pie_chart_rounded,
                                  size: 14,
                                  color: LightColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.translate('signup_hero_badge_budget'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: LightColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom-Left Floating Chip: Debt-free roadmap
                      Positioned(
                        bottom: 8,
                        left: 14,
                        child: Transform.translate(
                          offset: Offset(0, chip2Float),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? const Color(0xFF16231E)
                                  : white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: widget.isDark
                                    ? const Color(0xFF2E443A)
                                    : LightColors.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                width: 1.2,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: black.withValues(
                                    alpha: widget.isDark ? 0.35 : 0.08,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.trending_up_rounded,
                                  size: 14,
                                  color: healthyGreen,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.translate('signup_hero_badge_debt'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDark
                                        ? white
                                        : LightColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                context.translate('take_control_of_wealth'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: widget.isDark ? white : LightColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                context.translate('signup_hero_description'),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: widget.isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
