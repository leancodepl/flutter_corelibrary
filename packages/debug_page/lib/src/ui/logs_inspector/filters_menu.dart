import 'package:debug_page/src/request_log.dart';
import 'package:flutter/material.dart';

enum SearchType {
  endpoints,
  body,
  all,
}

class FiltersMenu extends StatefulWidget implements PreferredSizeWidget {
  const FiltersMenu({super.key});

  static const height = 250.0;

  @override
  State<StatefulWidget> createState() {
    return _FiltersMenuState();
  }

  @override
  Size get preferredSize => const Size.fromHeight(height);
}

class _FiltersMenuState extends State<FiltersMenu> {
  RequestStatus? requestStatus;
  SearchType? searchType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LabeledDropdown<RequestStatus>(
            title: const Text('Rodzaj'),
            onChanged: (value) => setState(() => requestStatus = value),
            options: const [
              (value: RequestStatus.success, label: '200'),
              (value: RequestStatus.redirect, label: '300'),
              (value: RequestStatus.error, label: '400'),
            ],
          ),
          _LabeledDropdown<SearchType>(
            title: const Text('Szukaj po'),
            onChanged: (value) => setState(() => searchType = value),
            options: const [
              (value: SearchType.endpoints, label: 'Endpointy'),
              (value: SearchType.body, label: 'Body'),
              (value: SearchType.all, label: 'All'),
            ],
          ),
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Szukaj',
              icon: Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatefulWidget {
  const _LabeledDropdown({
    required this.title,
    required this.options,
    required this.onChanged,
  });

  final Widget title;
  final List<({T value, String label})> options;
  final ValueChanged<T?> onChanged;

  @override
  State<StatefulWidget> createState() {
    return _LabeledDropdownState<T>();
  }
}

class _LabeledDropdownState<T> extends State<_LabeledDropdown<T>> {
  T? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.title,
        const SizedBox(width: 20),
        Expanded(
          child: DropdownButton<T>(
            isExpanded: true,
            value: selectedValue,
            onChanged: (value) {
              setState(() => selectedValue = value);
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
