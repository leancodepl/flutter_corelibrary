import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/core/filters/logger_filters.dart';
import 'package:debug_page/src/ui/colors.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/filtered_search_field.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/labeled_dropdown.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum LogSearchType {
  loggerName,
  logMessage,
  all,
}

class LoggerTabFiltersMenu extends StatefulWidget {
  const LoggerTabFiltersMenu({
    super.key,
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  State<LoggerTabFiltersMenu> createState() => _LoggerTabFiltersMenuState();
}

class _LoggerTabFiltersMenuState extends State<LoggerTabFiltersMenu> {
  Level? logLevel;
  var searchType = LogSearchType.all;
  String searchPhrase = '';

  @override
  void initState() {
    super.initState();

    final initialFilters = widget._controller.loggerFilters.value;

    for (final filter in initialFilters) {
      if (filter is LoggerLevelFilter) {
        logLevel = filter.desiredLevel;
      } else if (filter is LoggerSearchFilter) {
        searchType = filter.type;
        searchPhrase = filter.phrase;
      }
    }
  }

  void _updateFilters() {
    final logLevel = this.logLevel;
    final searchType = this.searchType;
    final searchPhrase = this.searchPhrase;

    widget._controller.loggerFilters.value = [
      if (logLevel != null) LoggerLevelFilter(desiredLevel: logLevel),
      if (searchPhrase.isNotEmpty)
        LoggerSearchFilter(
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
            LabeledDropdown<Level>(
              title: const Text('Level'),
              initialValue: logLevel,
              onChanged: (value) {
                setState(() => logLevel = value);
                _updateFilters();
              },
              options: const [
                (value: null, label: 'ALL'),
                (value: Level.CONFIG, label: 'CONFIG'),
                (value: Level.FINE, label: '<= FINE'),
                (value: Level.INFO, label: 'INFO'),
                (value: Level.WARNING, label: 'WARNING'),
                (value: Level.SEVERE, label: 'SEVERE'),
              ],
            ),
            FilteredSearchField<LogSearchType>(
              initialPhrase: searchPhrase,
              onPhraseChanged: (value) {
                searchPhrase = value;
                _updateFilters();
              },
              initialFilterValue: searchType,
              onFilterChanged: (value) {
                setState(() => searchType = value!);
                _updateFilters();
              },
              filterOptions: const [
                (label: 'All', value: LogSearchType.all),
                (label: 'Message', value: LogSearchType.logMessage),
                (label: 'Logger', value: LogSearchType.loggerName),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
