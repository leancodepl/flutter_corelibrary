import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/models/requests_log.dart';
import 'package:debug_page/src/ui/logs_inspector/search_field.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

enum SearchType {
  url,
  body,
  all,
}

class RequestsTabFiltersMenu extends StatefulWidget {
  const RequestsTabFiltersMenu({
    super.key,
    required this.onFiltersChanged,
  });

  final ValueChanged<List<IRequestFilter>> onFiltersChanged;

  @override
  State<StatefulWidget> createState() {
    return _RequestsTabFiltersMenuState();
  }
}

class _RequestsTabFiltersMenuState extends State<RequestsTabFiltersMenu> {
  RequestStatus? requestStatus;
  SearchType searchType = SearchType.url;
  String? searchPhrase;

  void _updateFilters() {
    final requestStatus = this.requestStatus;
    final searchType = this.searchType;
    final searchPhrase = this.searchPhrase;

    final filters = [
      if (requestStatus != null)
        RequestStatusFilter(desiredStatus: requestStatus),
      if (searchPhrase != null)
        RequestSearchFilter(
          type: searchType,
          phrase: searchPhrase,
        ),
    ];

    widget.onFiltersChanged(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: DefaultTextStyle(
        style: DebugPageTypography.medium,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LabeledDropdown<RequestStatus>(
              title: const Text('Type'),
              onChanged: (value) {
                setState(() => requestStatus = value);
                _updateFilters();
              },
              options: const [
                (value: null, label: 'Any'),
                (value: RequestStatus.success, label: '200'),
                (value: RequestStatus.redirect, label: '300'),
                (value: RequestStatus.error, label: '400'),
              ],
            ),
            _LabeledDropdown<SearchType>(
              title: const Text('Search by'),
              initialValue: searchType,
              onChanged: (value) {
                setState(() => searchType = value!);
                _updateFilters();
              },
              options: const [
                (value: SearchType.url, label: 'Url'),
                (value: SearchType.body, label: 'Body'),
                (value: SearchType.all, label: 'All'),
              ],
            ),
            SearchField(onChanged: (value) {
              searchPhrase = value;
              _updateFilters();
            }),
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
    this.initialValue,
  });

  final Widget title;
  final List<({T? value, String label})> options;
  final ValueChanged<T?> onChanged;
  final T? initialValue;

  @override
  State<StatefulWidget> createState() {
    return _LabeledDropdownState<T>();
  }
}

class _LabeledDropdownState<T> extends State<_LabeledDropdown<T>> {
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
