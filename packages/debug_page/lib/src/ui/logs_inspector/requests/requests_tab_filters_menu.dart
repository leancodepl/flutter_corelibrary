import 'package:debug_page/src/core/request_filters.dart';
import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/filtered_search_field.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/labeled_dropdown.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';

enum RequestSearchType {
  url,
  body,
  all,
}

class RequestsTabFiltersMenu extends StatefulWidget {
  const RequestsTabFiltersMenu({
    super.key,
    required this.onFiltersChanged,
  });

  final ValueChanged<List<Filter<RequestLogRecord>>> onFiltersChanged;

  @override
  State<StatefulWidget> createState() {
    return _RequestsTabFiltersMenuState();
  }
}

class _RequestsTabFiltersMenuState extends State<RequestsTabFiltersMenu> {
  RequestStatus? requestStatus;
  var searchType = RequestSearchType.url;
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
            LabeledDropdown<RequestStatus>(
              title: const Text('Type'),
              onChanged: (value) {
                setState(() => requestStatus = value);
                _updateFilters();
              },
              options: const [
                (value: null, label: 'Any'),
                (value: RequestStatus.success, label: '200'),
                (value: RequestStatus.redirect, label: '300'),
                (value: RequestStatus.clientError, label: '400'),
                (value: RequestStatus.serverError, label: '500'),
              ],
            ),
            FilteredSearchField(
              onPhraseChanged: (value) {
                searchPhrase = value;
                _updateFilters();
              },
              initialFilterValue: searchType,
              filterOptions: const [
                (value: RequestSearchType.url, label: 'Url'),
                (value: RequestSearchType.body, label: 'Body'),
                (value: RequestSearchType.all, label: 'All'),
              ],
              onFilterChanged: (value) {
                setState(() => searchType = value!);
                _updateFilters();
              },
            ),
          ],
        ),
      ),
    );
  }
}
