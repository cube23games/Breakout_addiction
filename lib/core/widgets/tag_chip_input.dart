import 'package:flutter/material.dart';

class TagChipInput extends StatefulWidget {
  const TagChipInput({
    required this.label,
    required this.hint,
    required this.values,
    required this.onChanged,
    super.key,
  });
  final String label;
  final String hint;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  @override
  State<TagChipInput> createState() => _TagChipInputState();
}

class _TagChipInputState extends State<TagChipInput> {
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _addRaw(String raw) {
    final candidates = raw.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty);
    final next = [...widget.values];
    for (final candidate in candidates) {
      if (!next.any((item) => item.toLowerCase() == candidate.toLowerCase())) next.add(candidate);
    }
    _controller.clear();
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      if (widget.values.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in widget.values)
              InputChip(
                label: Text(value),
                onDeleted: () => widget.onChanged(widget.values.where((item) => item != value).toList()),
              ),
          ],
        ),
      if (widget.values.isNotEmpty) const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: widget.hint, border: const OutlineInputBorder()),
            onSubmitted: _addRaw,
            onChanged: (value) {
              if (value.endsWith(',')) _addRaw(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Add ${widget.label}',
          onPressed: () => _addRaw(_controller.text),
          icon: const Icon(Icons.add),
        ),
      ]),
    ]);
  }
}
