import 'package:debug_page/src/ui/logs_inspector/widgets/labeled_dropdown.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/search_field.dart';
import 'package:flutter/material.dart';

class FilteredSearchField<T> extends StatelessWidget {
  const FilteredSearchField({
    super.key,
    required this.onPhraseChanged,
    required this.initialFilterValue,
    required this.filterOptions,
    required this.onFilterChanged,
  });

  final ValueChanged<String> onPhraseChanged;
  final T initialFilterValue;
  final List<DropdownOption<T>> filterOptions;
  final ValueChanged<T?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 3,
          child: SearchField(onChanged: onPhraseChanged),
        ),
        Flexible(
          flex: 2,
          child: LabeledDropdown<T>(
            title: const Text('by'),
            initialValue: initialFilterValue,
            onChanged: onFilterChanged,
            options: filterOptions,
          ),
        ),
      ],
    );
  }
}
