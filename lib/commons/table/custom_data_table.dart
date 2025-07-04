import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomDataTable<T> extends StatefulWidget {
  final List<Widget> headers;
  final List<String> dataColumns;
  final List<T> data;
  final List<Widget> Function(T) rowBuilder;
  final Widget paginator;
  final Widget Function(T item)? popupMenuBuilder;

  const CustomDataTable({
    super.key,
    required this.headers,
    required this.dataColumns,
    required this.data,
    required this.rowBuilder,
    required this.paginator,
    this.popupMenuBuilder,
  });

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  int? _hoveredIndex;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: widget.headers,
        ),
        const SizedBox(
          height: 50.0,
        ),
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
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 40.0,
            ),
          ],
        ),
        Expanded(
          child: widget.data.isEmpty
              ? Center(
                  child: Text(
                    'No data to display',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: greyHard,
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
                        color:
                            index.isEven ? LightColors.background : transparent,
                        child: Container(
                          color: isHovered
                              ? LightColors.primary.withValues(
                                  alpha: 0.1,
                                )
                              : transparent,
                          height: 50.0,
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
        // widget.paginator,
      ],
    );
  }
}
