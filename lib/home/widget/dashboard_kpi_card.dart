part of 'home_body.dart';

class DashboardKpiCard extends StatelessWidget {
  final KpiCardSpec spec;

  const DashboardKpiCard({super.key, required this.spec});

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final bool hasSubtitle =
        spec.subtitle != null && spec.subtitle!.trim().isNotEmpty;

    return KpiInfoTooltip(
      title: spec.title,
      description: spec.description,
      calculation: spec.calculation,
      child: Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.primary,
            width: 1.0,
          ),
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
                decoration: BoxDecoration(
                  color: isDark ? DarkColors.primary : LightColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(spec.icon, color: white, size: 20),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            spec.title,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (spec.changePercent != null) ...<Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: spec.isPositive
                                  ? (isDark
                                        ? LightColors.primary.withValues(
                                            alpha: 0.2,
                                          )
                                        : const Color(0xFFE6FBF4))
                                  : (isDark
                                        ? Colors.red.withValues(alpha: 0.2)
                                        : Colors.red[50]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${spec.isPositive ? "+" : ""}${spec.changePercent}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: spec.isPositive
                                    ? (isDark
                                          ? LightColors.primary
                                          : const Color(0xFF07882E))
                                    : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spec.amount,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 17 : 19,
                        fontWeight: FontWeight.bold,
                        color: isDark ? white : LightColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasSubtitle) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        spec.subtitle!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
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
