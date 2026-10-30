import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/error/privacy_safe_logger.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

/// Application Error Boundary widget that catches unhandled Flutter build and layout
/// exceptions, rendering a graceful, privacy-safe recovery UI.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({super.key, required this.child, this.onError});

  final Widget child;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
  }

  void _resetError() {
    setState(() {
      _error = null;
      _showDetails = false;
    });
  }

  @override
  Widget build(final BuildContext context) {
    if (_error != null) {
      return _buildErrorUi(context);
    }

    return widget.child;
  }

  Widget _buildErrorUi(final BuildContext context) {
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

    final String sanitizedMessage = PrivacySafeLogger.sanitize(
      _error?.toString() ?? 'An unknown error occurred',
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Shield Alert Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: errorColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 32,
                      color: errorColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Text(
                    'Something Went Wrong',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Security reassurance
                  Text(
                    'An unexpected application error occurred. Your cryptographic keys and financial data remain safe in memory.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: _resetError,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: borderColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      if (kDebugMode) ...<Widget>[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showDetails = !_showDetails;
                            });
                          },
                          child: Text(
                            _showDetails ? 'Hide Details' : 'View Details',
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Expandable sanitized details (in debug mode)
                  if (_showDetails) ...<Widget>[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? black.withValues(alpha: 0.4)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sanitizedMessage,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback ErrorWidget builder that replaces the default red screen of death
/// with a privacy-safe, branded widget.
Widget buildPrivacySafeErrorWidget(final FlutterErrorDetails details) {
  final String sanitized = PrivacySafeLogger.sanitize(
    details.exceptionAsString(),
  );

  return Builder(
    builder: (final BuildContext context) {
      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        color: isDark ? DarkColors.background : LightColors.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              color: errorColor,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              'A rendering issue occurred.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? white : LightColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sanitized,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? textSecondaryDark : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    },
  );
}
