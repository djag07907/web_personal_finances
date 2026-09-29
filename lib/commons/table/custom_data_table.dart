import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomDataTable<T> extends StatefulWidget {
  final List<Widget>? headers;
  final List<String> dataColumns;
  final List<T> data;
  final List<Widget> Function(T) rowBuilder;
  final Widget paginator;
  final Widget Function(T item)? popupMenuBuilder;
  final VoidCallback? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onExport;
  final bool showToolbar;
  final String? searchHint;

  const CustomDataTable({
    super.key,
    this.headers,
    required this.dataColumns,
    required this.data,
    required this.rowBuilder,
    required this.paginator,
    this.popupMenuBuilder,
    this.onSearch,
    this.onFilter,
    this.onExport,
    this.showToolbar = true,
    this.searchHint,
  });

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  int? _hoveredIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: <Widget>[
        Row(children: widget.headers ?? <Widget>[]),
        const SizedBox(height: 16.0),
        if (widget.showToolbar) _buildToolbar(context, isDark),
        const SizedBox(height: 16.0),
        Row(
          children: <Widget>[
            ...widget.dataColumns.map(
              (final String column) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    column,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: isDark ? DarkColors.textSecondary : greyHard,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40.0),
          ],
        ),
        const SizedBox(height: 12.0),
        Expanded(
          child: widget.data.isEmpty
              ? Center(
                  child: Text(
                    'No data to display',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDark ? DarkColors.textSecondary : greyHard,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView(
                  children: widget.data.map((final T rowItem) {
                    final int index = widget.data.indexOf(rowItem);
                    final List<Widget> cell = widget.rowBuilder(rowItem);
                    final bool isHovered = _hoveredIndex == index;

                    return MouseRegion(
                      onEnter: (final PointerEvent row) {
                        setState(() => _hoveredIndex = index);
                      },
                      onExit: (final PointerEvent row) {
                        setState(() => _hoveredIndex = null);
                      },
                      child: Container(
                        color: index.isEven
                            ? (isDark
                                  ? DarkColors.background
                                  : LightColors.background)
                            : transparent,
                        child: Container(
                          color: isHovered
                              ? (isDark
                                    ? DarkColors.primary.withValues(alpha: 0.1)
                                    : LightColors.primary.withValues(
                                        alpha: 0.1,
                                      ))
                              : transparent,
                          height: 60.0,
                          child: Row(
                            children: <Widget>[
                              ...cell.map((final Widget cell) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: cell,
                                    ),
                                  ),
                                );
                              }),
                              if (widget.popupMenuBuilder != null)
                                widget.popupMenuBuilder!(rowItem),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: widget.paginator,
        ),
      ],
    );
  }

  Widget _buildToolbar(final BuildContext context, final bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark
            ? DarkColors.surface.withValues(alpha: 0.5)
            : Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(
            color: isDark ? DarkColors.border : Color(0xFFE5E7EB),
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? DarkColors.background : white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? DarkColors.border : Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? white : LightColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? 'Search...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDark ? DarkColors.textSecondary : Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: isDark ? DarkColors.textSecondary : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (final String value) {
                  if (widget.onSearch != null) {
                    widget.onSearch!();
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          if (widget.onFilter != null)
            _buildToolbarButton(
              context,
              isDark,
              icon: Icons.filter_list,
              label: 'Filter',
              onPressed: widget.onFilter,
            ),
          SizedBox(width: 8),
          if (widget.onExport != null)
            _buildToolbarButton(
              context,
              isDark,
              icon: Icons.ios_share,
              label: 'Export',
              onPressed: widget.onExport,
            ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
    final BuildContext context,
    final bool isDark, {
    required final IconData icon,
    required final String label,
    final VoidCallback? onPressed,
  }) {
    return Material(
      color: transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? DarkColors.background : white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? DarkColors.border : Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: isDark ? DarkColors.textSecondary : Colors.grey[600],
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? DarkColors.textPrimary : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
