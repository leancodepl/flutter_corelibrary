part of '../mock_libraries.dart';

mixin MockSliverTools on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('sliver_tools').addFile('lib/sliver_tools.dart', '''
import 'package:flutter/material.dart';

class MultiSliver extends StatelessWidget {
  MultiSliver({required List<Widget> children});
}
''');
    super.setUp();
  }
}
