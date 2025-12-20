import 'package:flutter/material.dart';
import 'package:web_personal_finances/resources/colors_constants.dart';

class CustomChipTag extends StatefulWidget {
  final List<String> initialTags;
  final void Function(List<String>) onChanged;
  final String label;
  final String hintText;

  const CustomChipTag({
    super.key,
    required this.initialTags,
    required this.onChanged,
    required this.label,
    required this.hintText,
  });

  @override
  State<CustomChipTag> createState() => _CustomChipTagState();
}

class _CustomChipTagState extends State<CustomChipTag> {
  final TextEditingController _tagController = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.initialTags);
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
        widget.onChanged(_tags);
      });
    }
  }

  void _removeTag(final String tag) {
    setState(() {
      _tags.remove(tag);
      widget.onChanged(_tags);
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _tags
              .map(
                (final String tag) => Chip(
                  label: Text(tag),
                  labelStyle: const TextStyle(
                    color: white,
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    color: white,
                  ),
                  backgroundColor: LightColors.primary.withValues(
                    alpha: 20,
                  ),
                  onDeleted: () => _removeTag(tag),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0,
          ),
          child: TextField(
            controller: _tagController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              fillColor: white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addTag(
                  _tagController.text,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            onSubmitted: _addTag,
          ),
        ),
      ],
    );
  }
}
