import 'package:debug_page/src/models/request_log.dart';
import 'package:debug_page/src/ui/logs_inspector/search_field.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

enum SearchType {
  endpoints,
  body,
  all,
}

class RequestsTabFiltersMenu extends StatefulWidget {
  const RequestsTabFiltersMenu({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RequestsTabFiltersMenuState();
  }
}

class _RequestsTabFiltersMenuState extends State<RequestsTabFiltersMenu> {
  RequestStatus? requestStatus;
  SearchType? searchType;
  String? searchPhrase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: DefaultTextStyle(
        style: DebugPageTypography.medium,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LabeledDropdown<RequestStatus>(
              title: const Text('Type'),
              onChanged: (value) => setState(() => requestStatus = value),
              options: const [
                (value: RequestStatus.success, label: '200'),
                (value: RequestStatus.redirect, label: '300'),
                (value: RequestStatus.error, label: '400'),
              ],
            ),
            _LabeledDropdown<SearchType>(
              title: const Text('Search by'),
              onChanged: (value) => setState(() => searchType = value),
              options: const [
                (value: SearchType.endpoints, label: 'Endpoint'),
                (value: SearchType.body, label: 'Body'),
                (value: SearchType.all, label: 'All'),
              ],
            ),
            SearchField(onChanged: (value) => searchPhrase = value),
          ],
        ),
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
  T? _selectedValue;

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
