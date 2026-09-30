import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';
import 'package:web_personal_finances/resources/constants.dart';

class CustomLabelSelector extends StatefulWidget {
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomLabelSelector({
    super.key,
    required this.label,
    required this.hintText,
    required this.validator,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  State<CustomLabelSelector> createState() => _CustomLabelSelectorState();
}

class _CustomLabelSelectorState extends State<CustomLabelSelector> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _inputKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleOverlay(final FormFieldState<String> state, final bool isDark) {
    if (_isOpen) {
      _hideOverlay();
    } else {
      _showOverlay(state, isDark);
    }
  }

  void _showOverlay(final FormFieldState<String> state, final bool isDark) {
    final RenderBox? targetBox =
        _inputKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) return;

    final Size inputSize = targetBox.size;

    _overlayEntry = OverlayEntry(
      builder: (final BuildContext context) {
        final String? currentValue = state.value ?? widget.selectedValue;

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              width: inputSize.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, inputSize.height + 2.0),
                child: Material(
                  color: transparent,
                  elevation: 8,
                  shadowColor: black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    decoration: BoxDecoration(
                      color: isDark ? DarkColors.surface : white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? DarkColors.border
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(6),
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        separatorBuilder:
                            (final BuildContext context, final int index) =>
                                const SizedBox(height: 4),
                        itemBuilder:
                            (final BuildContext context, final int index) {
                              final String item = widget.items[index];
                              final bool isSelected = item == currentValue;

                              return Material(
                                color: transparent,
                                child: InkWell(
                                  onTap: () {
                                    state.didChange(item);
                                    widget.onChanged(item);
                                    _hideOverlay();
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  hoverColor: LightColors.primary.withValues(
                                    alpha: 0.06,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark
                                                ? LightColors.primary
                                                      .withValues(alpha: 0.15)
                                                : LightColors.primary
                                                      .withValues(alpha: 0.08))
                                          : transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? LightColors.primary
                                                : (isDark
                                                      ? DarkColors.textPrimary
                                                      : LightColors
                                                            .textPrimary),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: LightColors.primary,
                                            size: 18,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _hideOverlay() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() {
          _isOpen = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return FormField<String>(
      initialValue: widget.selectedValue,
      validator: widget.validator,
      builder: (final FormFieldState<String> state) {
        final bool hasError = state.hasError;
        final String? currentValue = state.value ?? widget.selectedValue;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              CompositedTransformTarget(
                key: _inputKey,
                link: _layerLink,
                child: Material(
                  color: transparent,
                  child: InkWell(
                    onTap: () => _toggleOverlay(state, isDark),
                    borderRadius: BorderRadius.circular(14.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 13.0,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? DarkColors.surface : white,
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: hasError
                              ? Colors.red
                              : (_isOpen
                                    ? (isDark
                                          ? DarkColors.primary
                                          : LightColors.primary)
                                    : (isDark
                                          ? DarkColors.border
                                          : Colors.grey.shade300)),
                          width: (hasError || _isOpen) ? 2.0 : 1.0,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              currentValue != null && currentValue.isNotEmpty
                                  ? currentValue
                                  : widget.hintText,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    currentValue != null &&
                                        currentValue.isNotEmpty
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                color:
                                    currentValue != null &&
                                        currentValue.isNotEmpty
                                    ? (isDark
                                          ? DarkColors.textPrimary
                                          : LightColors.textPrimary)
                                    : (isDark
                                          ? DarkColors.textSecondary
                                          : Colors.grey[400]),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AnimatedRotation(
                            turns: _isOpen ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? DarkColors.surfaceLight
                                    : LightColors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                  child: Text(
                    state.errorText ?? emptyString,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
