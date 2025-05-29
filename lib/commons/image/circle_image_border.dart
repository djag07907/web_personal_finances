import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CircularImageBorder extends StatelessWidget {
  final double minHeight;
  final double minWidth;
  final double borderWidth;
  final Color borderColor;
  final String? imagePath;
  final String? labelImage;

  const CircularImageBorder({
    super.key,
    this.borderWidth = 5,
    this.borderColor = LightColors.primary,
    this.imagePath,
    this.labelImage,
    required this.minHeight,
    required this.minWidth,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(
        minHeight: minHeight,
        minWidth: minWidth,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: borderWidth,
          color: borderColor.withValues(alpha: 0.6),
        ),
      ),
      child: CircleAvatar(
        backgroundColor: LightColors.primary.withValues(alpha: 0.8),
        child: imagePath != null ? _buildImageAsset() : _builTextImage(),
      ),
    );
  }

  Widget _buildImageAsset() {
    return Image.asset(
      imagePath!,
      fit: BoxFit.contain,
    );
  }

  Widget _builTextImage() {
    String initials = labelImage!
        .trim()
        .split(RegExp(' +'))
        .where((final String name) => name.isNotEmpty)
        .map((final String name) => name[0])
        .take(2)
        .join()
        .toUpperCase();

    return Text(
      initials,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
