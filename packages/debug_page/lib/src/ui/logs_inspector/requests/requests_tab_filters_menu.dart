import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/core/filters/request_filters.dart';
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
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  State<StatefulWidget> createState() {
    return _RequestsTabFiltersMenuState();
  }
}

class _RequestsTabFiltersMenuState extends State<RequestsTabFiltersMenu> {
  RequestStatus? requestStatus;
  RequestSearchType searchType = RequestSearchType.url;
  String searchPhrase = '';

  @override
  void initState() {
    super.initState();

    final initialFilters = widget._controller.requestsFilters.value;

    for (final filter in initialFilters) {
      if (filter is RequestStatusFilter) {
        requestStatus = filter.desiredStatus;
      } else if (filter is RequestSearchFilter) {
        searchType = filter.type;
        searchPhrase = filter.phrase;
      }
    }
  }

  void _updateFilters() {
    final requestStatus = this.requestStatus;
    final searchType = this.searchType;
    final searchPhrase = this.searchPhrase;

    widget._controller.requestsFilters.value = [
      if (requestStatus != null)
        RequestStatusFilter(desiredStatus: requestStatus),
      if (searchPhrase.isNotEmpty)
        RequestSearchFilter(
          type: searchType,
          phrase: searchPhrase,
        ),
    ];
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
              initialValue: requestStatus,
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
              initialPhrase: searchPhrase,
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
