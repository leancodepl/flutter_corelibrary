import 'package:flutter/material.dart';

typedef DropdownOption<T> = ({T? value, String label});

class LabeledDropdown<T> extends StatefulWidget {
  const LabeledDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.onChanged,
    this.initialValue,
  });

  final Widget title;
  final List<DropdownOption<T>> options;
  final ValueChanged<T?> onChanged;
  final T? initialValue;

  @override
  State<StatefulWidget> createState() {
    return _LabeledDropdownState<T>();
  }
}

class _LabeledDropdownState<T> extends State<LabeledDropdown<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.title,
        const SizedBox(width: 20),
        Expanded(
          child: DropdownButton<T>(
            isExpanded: true,
            value: _selectedValue,
            onChanged: (value) {
              setState(() => _selectedValue = value);
              widget.onChanged(value);
            },
            items: widget.options
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item.value,
                    child: Text(item.label),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}
