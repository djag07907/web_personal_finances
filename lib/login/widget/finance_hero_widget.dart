import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

/// A lightweight, pure-Flutter animated financial showcase widget for hero sections.
/// Runs at a buttery-smooth 60fps on web browsers without any external assets,
/// Lottie dependencies, or heavy canvas operations.
class FinanceHeroWidget extends StatefulWidget {
  const FinanceHeroWidget({
    super.key,
    required this.isDark,
    this.title,
    this.description,
  });

  final bool isDark;
  final String? title;
  final String? description;

  @override
  State<FinanceHeroWidget> createState() => _FinanceHeroWidgetState();
}

class _FinanceHeroWidgetState extends State<FinanceHeroWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Visual Animation Container (Scales down gracefully on narrow desktop splits)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 380,
                  height: 270,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Ambient radial glow behind the card
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

                      // Main Floating Finance Card
                      Transform.translate(
                        offset: Offset(0, cardFloat),
                        child: Container(
                          width: 310,
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
                              // Card Header: Icon, Portfolio Title, and Live indicator
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
                                      Icons.account_balance_wallet_rounded,
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
                                            'hero_portfolio_title',
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
                                          r'$ 128,450.00',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 17,
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
                                  // Live beacon badge
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
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: healthyGreen.withValues(
                                              alpha: 0.5 + (0.5 * pulse),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          context.translate('hero_chart_live'),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: healthyGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Dynamic Live Spline Chart
                              SizedBox(
                                height: 65,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: _FinanceChartPainter(
                                    animationProgress: t,
                                    isDark: widget.isDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Card Footer: Growth & Currency chips
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.trending_up_rounded,
                                          size: 14,
                                          color: healthyGreen,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            context.translate(
                                              'hero_stat_growth',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
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
                                        Icon(
                                          Icons.currency_exchange_rounded,
                                          size: 13,
                                          color: widget.isDark
                                              ? DarkColors.textSecondary
                                              : LightColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            context.translate(
                                              'hero_stat_currency',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
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

                      // Top-Right Floating Metric Chip
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.insights_rounded,
                                  size: 15,
                                  color: LightColors.primary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '+32.4%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: LightColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom-Left Floating Security Chip
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
                                  Icons.shield_rounded,
                                  size: 14,
                                  color: LightColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.translate('hero_stat_security'),
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
                widget.title ?? context.translate('login_hero_title'),
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
                widget.description ??
                    context.translate('login_hero_description'),
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

/// Custom painter for a sleek, real-time oscillating financial growth spline.
class _FinanceChartPainter extends CustomPainter {
  const _FinanceChartPainter({
    required this.animationProgress,
    required this.isDark,
  });

  final double animationProgress;
  final bool isDark;

  @override
  void paint(final Canvas canvas, final Size size) {
    final double w = size.width;
    final double h = size.height;

    // Harmonic points on an upward trending financial curve
    final double p0x = 0.0;
    final double p0y = h * 0.82;

    final double p1x = w * 0.26;
    final double p1y =
        h * (0.65 + (0.07 * math.sin(animationProgress * 2 * math.pi)));

    final double p2x = w * 0.54;
    final double p2y =
        h * (0.46 + (0.06 * math.cos(animationProgress * 2 * math.pi)));

    final double p3x = w * 0.78;
    final double p3y =
        h * (0.28 + (0.06 * math.sin((animationProgress * 2 * math.pi) + 1.2)));

    final double p4x = w;
    final double p4y =
        h * (0.14 + (0.04 * math.sin((animationProgress * 2 * math.pi) + 2.4)));

    // Create line path
    final Path linePath = Path()..moveTo(p0x, p0y);

    // Smooth spline segments
    linePath.cubicTo(w * 0.13, p0y, p1x - (w * 0.08), p1y, p1x, p1y);
    linePath.cubicTo(p1x + (w * 0.10), p1y, p2x - (w * 0.10), p2y, p2x, p2y);
    linePath.cubicTo(p2x + (w * 0.08), p2y, p3x - (w * 0.08), p3y, p3x, p3y);
    linePath.cubicTo(p3x + (w * 0.08), p3y, p4x - (w * 0.06), p4y, p4x, p4y);

    // Fill path under the curve
    final Path fillPath = Path.from(linePath)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          LightColors.primary.withValues(alpha: isDark ? 0.32 : 0.22),
          LightColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final Paint linePaint = Paint()
      ..color = LightColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(linePath, linePaint);

    // Peak animated pulsing beacon dot
    final double pulsePhase =
        (math.sin(animationProgress * 4 * math.pi) + 1.0) / 2.0;

    final Paint outerBeaconPaint = Paint()
      ..color = LightColors.primary.withValues(
        alpha: 0.35 * (1.0 - (pulsePhase * 0.5)),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(p4x, p4y),
      5.0 + (3.0 * pulsePhase),
      outerBeaconPaint,
    );

    final Paint innerBeaconPaint = Paint()
      ..color = white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(p4x, p4y), 3.0, innerBeaconPaint);
  }

  @override
  bool shouldRepaint(covariant final _FinanceChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.isDark != isDark;
  }
}

/// Lightweight dot matrix background pattern for hero visual panels.
class DotPatternPainter extends CustomPainter {
  const DotPatternPainter({this.dotColor});

  final Color? dotColor;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()
      ..color = dotColor ?? LightColors.primary
      ..style = PaintingStyle.fill;

    const double spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => false;
}
