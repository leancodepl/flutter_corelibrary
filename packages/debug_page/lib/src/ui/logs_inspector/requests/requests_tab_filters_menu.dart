import 'package:debug_page/src/core/filters/request_filters.dart';
import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/colors.dart';
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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      color: DebugPageColors.background,
      child: DefaultTextStyle(
        style: DebugPageTypography.medium,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledDropdown<RequestStatus>(
              title: const Text('Status code'),
              onChanged: (value) {
                setState(() => requestStatus = value);
                _updateFilters();
              },
              options: const [
                (value: null, label: 'Any'),
                (value: RequestStatus.success, label: '2xx'),
                (value: RequestStatus.redirect, label: '3xx'),
                (value: RequestStatus.clientError, label: '4xx'),
                (value: RequestStatus.serverError, label: '5xx'),
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
