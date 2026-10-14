part of 'accounts_to_pay_body.dart';

class AccountToPayStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final bool isPositive;
  final IconData icon;
  final String? description;
  final String? calculation;

  const AccountToPayStatCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.isPositive = true,
    required this.icon,
    this.description,
    this.calculation,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return KpiInfoTooltip(
      title: title,
      description: description,
      calculation: calculation,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LightColors.primary, width: 1.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: 12,
          ),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: LightColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: white, size: 20),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? white : LightColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (hasSubtitle) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
