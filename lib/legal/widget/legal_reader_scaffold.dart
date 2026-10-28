import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';
import 'package:web_personal_finances/routes/landing_routes.dart';

class LegalReaderScaffold extends StatelessWidget {
  const LegalReaderScaffold({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.badgeText,
    required this.children,
    this.badgeIcon = Icons.shield_outlined,
  });

  final String title;
  final String lastUpdated;
  final String badgeText;
  final IconData badgeIcon;
  final List<Widget> children;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? DarkColors.background
        : LightColors.background;
    final Color cardColor = isDark ? DarkColors.surface : white;
    final Color borderColor = isDark
        ? const Color(0xFF2A3632)
        : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? white : LightColors.textPrimary;
    final Color textSecondary = isDark
        ? textSecondaryDark
        : LightColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LayoutBuilder(
                    builder:
                        (
                          final BuildContext ctx,
                          final BoxConstraints constraints,
                        ) {
                          final bool isCompact = constraints.maxWidth < 540;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // Left Brand
                              InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(loginRoute);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          pecuniaLogoPath,
                                          height: 34,
                                          width: 34,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        appName,
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                          color: textPrimary,
                                        ),
                                      ),
                                      if (!isCompact) ...<Widget>[
                                        const SizedBox(width: 12),
                                        Container(
                                          height: 16,
                                          width: 1.5,
                                          color: borderColor,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Legal & Security',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              // Right Action Button
                              OutlinedButton.icon(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go(signupRoute);
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  isCompact ? 'Back' : 'Back to Sign Up',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textPrimary,
                                  side: BorderSide(color: borderColor),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: LightColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(badgeIcon, size: 16, color: LightColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: LightColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle & Last updated
                  Text(
                    'Last Updated: $lastUpdated',
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: borderColor),
                  const SizedBox(height: 20),

                  // Document sections
                  ...children,

                  const SizedBox(height: 40),
                  Divider(color: borderColor),
                  const SizedBox(height: 24),

                  // Document Footer
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        '© 2026 $appName Personal Finances. All rights reserved.',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextButton(
                            onPressed: () => context.go(termsRoute),
                            child: const Text('Terms of Service'),
                          ),
                          const SizedBox(width: 8),
                          Text('•', style: TextStyle(color: textSecondary)),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => context.go(privacyRoute),
                            child: const Text('Privacy Policy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  const LegalSection({
    super.key,
    required this.number,
    required this.title,
    required this.content,
  });

  final String number;
  final String title;
  final Widget content;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = isDark ? white : LightColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: LightColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: LightColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

class LegalParagraph extends StatelessWidget {
  const LegalParagraph(this.text, {super.key});

  final String text;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark
        ? Colors.grey[300]!
        : const Color(0xFF4A5568);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.5, height: 1.65, color: textColor),
      ),
    );
  }
}

class LegalHighlightBox extends StatelessWidget {
  const LegalHighlightBox({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColors.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: LightColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: LightColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LegalSubheading extends StatelessWidget {
  const LegalSubheading(this.title, {super.key});

  final String title;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: isDark ? white : LightColors.textPrimary,
        ),
      ),
    );
  }
}

class LegalBulletPoint extends StatelessWidget {
  const LegalBulletPoint({
    super.key,
    required this.boldPrefix,
    required this.text,
  });

  final String boldPrefix;
  final String text;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark
        ? Colors.grey[300]!
        : const Color(0xFF4A5568);

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 7, right: 10),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: LightColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.5, height: 1.6, color: textColor),
                children: <TextSpan>[
                  if (boldPrefix.isNotEmpty)
                    TextSpan(
                      text: '$boldPrefix: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? white : LightColors.textPrimary,
                      ),
                    ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
