import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

/// Wraps a KPI card and shows a popup on hover (long-press on touch devices)
/// explaining what the KPI means and how it is calculated.
class KpiInfoTooltip extends StatelessWidget {
  const KpiInfoTooltip({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.calculation,
  });

  final String title;
  final String? description;
  final String? calculation;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final bool hasDescription = description != null && description!.isNotEmpty;
    final bool hasCalculation = calculation != null && calculation!.isNotEmpty;
    if (!hasDescription && !hasCalculation) {
      return child;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF2A2F3A) : const Color(0xFF1F2937);
    final Color accent = isDark ? DarkColors.primary : LightColors.primary;

    return Tooltip(
      waitDuration: const Duration(milliseconds: 250),
      showDuration: const Duration(seconds: 8),
      preferBelow: true,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      richMessage: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          if (hasDescription)
            TextSpan(
              text: '\n$description',
              style: const TextStyle(fontSize: 12, height: 1.4, color: white),
            ),
          if (hasCalculation) ...<InlineSpan>[
            TextSpan(
              text: '\n\nHow it is calculated',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
            TextSpan(
              text: '\n$calculation',
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
      child: MouseRegion(cursor: SystemMouseCursors.help, child: child),
    );
  }
}
