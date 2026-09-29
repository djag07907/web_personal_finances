import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class DrawerWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;

  const DrawerWidget({
    super.key,
    required this.title,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            bottomLeft: Radius.circular(20.0),
          ),
          border: isDark
              ? Border(left: BorderSide(color: DarkColors.border, width: 1))
              : null,
          boxShadow: <BoxShadow>[
            BoxShadow(
              blurRadius: 20,
              color: black.withValues(alpha: isDark ? 0.5 : 0.15),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? DarkColors.primary : LightColors.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? DarkColors.textSecondary : null,
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
