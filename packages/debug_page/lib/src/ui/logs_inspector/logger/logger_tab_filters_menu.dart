import 'package:debug_page/src/core/logger_filters.dart';
import 'package:debug_page/src/models/filter.dart';
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
    required this.onFiltersChanged,
  });

  final ValueChanged<List<Filter<LogRecord>>> onFiltersChanged;

  @override
  State<LoggerTabFiltersMenu> createState() => _LoggerTabFiltersMenuState();
}

class _LoggerTabFiltersMenuState extends State<LoggerTabFiltersMenu> {
  Level? logLevel;
  var searchType = LogSearchType.all;
  String? searchPhrase;

  void _updateFilters() {
    final logLevel = this.logLevel;
    final searchType = this.searchType;
    final searchPhrase = this.searchPhrase;

    final filters = [
      if (logLevel != null) LoggerLevelFilter(desiredLevel: logLevel),
      if (searchPhrase != null)
        LoggerSearchFilter(
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
            LabeledDropdown<Level>(
              title: const Text('Level'),
              initialValue: null,
              onChanged: (value) {
                setState(() => logLevel = value);
                _updateFilters();
              },
              options: const [
                (value: null, label: 'ALL'),
                (value: Level.CONFIG, label: 'CONFIG'),
                (value: Level.FINE, label: 'FINE'),
                (value: Level.INFO, label: 'INFO'),
                (value: Level.WARNING, label: 'WARNING'),
                (value: Level.SEVERE, label: 'SEVERE'),
              ],
            ),
            FilteredSearchField<LogSearchType>(
              onPhraseChanged: (value) {
                searchPhrase = value;
                _updateFilters();
              },
              onFilterChanged: (value) {},
              initialFilterValue: LogSearchType.all,
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
