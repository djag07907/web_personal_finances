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
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            bottomLeft: Radius.circular(20.0),
          ),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LightColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
