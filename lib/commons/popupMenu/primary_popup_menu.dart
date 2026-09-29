import 'package:flutter/material.dart';
import 'package:web_personal_finances/commons/popupMenu/popup_item.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class PrimaryPopupMenu<T> extends StatelessWidget {
  final Widget? child;
  final List<PopupItem<T>> popupItems;
  final String tooltip;
  final void Function(T)? onSelect;

  const PrimaryPopupMenu({
    super.key,
    required this.popupItems,
    this.child,
    this.tooltip = emptyString,
    this.onSelect,
  });

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<T>(
      padding: EdgeInsets.zero,
      splashRadius: 1.0,
      menuPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      ),
      itemBuilder: (final BuildContext ctx) => _buildList(ctx, isDark),
      tooltip: tooltip,
      icon: Icon(
        Icons.more_vert,
        color: isDark ? DarkColors.textSecondary : black,
      ),
      position: PopupMenuPosition.under,
      color: isDark ? DarkColors.surface : white,
      constraints: BoxConstraints(maxWidth: 110.0, maxHeight: 170),
      child: child,
    );
  }

  List<PopupMenuEntry<T>> _buildList(
    final BuildContext context,
    final bool isDark,
  ) {
    List<PopupMenuEntry<T>> menuItems = <PopupMenuEntry<T>>[];
    for (int i = 0; i < popupItems.length; i++) {
      final PopupItem<T> item = popupItems[i];
      menuItems.add(
        PopupMenuItem<T>(
          value: item.value,
          padding: EdgeInsets.zero,
          child: _HoverableMenuItem<T>(
            item: item,
            isDark: isDark,
            onTap: () {
              if (onSelect != null) {
                onSelect!(item.value);
              }
            },
          ),
        ),
      );
      if (i < popupItems.length - 1) {
        menuItems.add(
          PopupMenuItem<T>(
            enabled: false,
            padding: EdgeInsets.zero,
            textStyle: TextStyle(
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
            height: 1.0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              height: 1,
              color: isDark ? DarkColors.border : LightColors.greyBackground,
            ),
          ),
        );
      }
    }
    return menuItems;
  }
}

class _HoverableMenuItem<T> extends StatefulWidget {
  final PopupItem<T> item;
  final bool isDark;
  final VoidCallback? onTap;

  const _HoverableMenuItem({
    required this.item,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_HoverableMenuItem<T>> createState() => _HoverableMenuItemState<T>();
}

class _HoverableMenuItemState<T> extends State<_HoverableMenuItem<T>> {
  bool _isHovered = false;

  @override
  Widget build(final BuildContext context) {
    final Color hoverBg = widget.isDark
        ? DarkColors.primary.withValues(alpha: 0.15)
        : LightColors.primary.withValues(alpha: 0.1);
    final Color textColor = _isHovered
        ? (widget.isDark ? DarkColors.primary : LightColors.primary)
        : (widget.isDark ? DarkColors.textSecondary : greyHard);

    return MouseRegion(
      onEnter: (final _) => setState(() => _isHovered = true),
      onExit: (final _) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: hoverBg,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? hoverBg : transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          width: double.infinity,
          child: Text(
            widget.item.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
