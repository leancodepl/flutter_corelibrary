// ignored for lint test purpose
// ignore_for_file: unused_field, prefer_final_fields, unused_element, use_design_system_item, use_design_system_item_LftText

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MissingDisposeStatefulWidget extends StatefulWidget {
  MissingDisposeStatefulWidget({
    super.key,
    required this.scrollController,
    required FocusNode focusNode,
  }) : _focusNode = focusNode,
       _streamController = StreamController<String>();
  // expect_lint: avoid_missing_dispose
  final controller = TextEditingController();
  final ScrollController scrollController;
  final FocusNode _focusNode;
  final StreamController<String> _streamController;

  @override
  State<MissingDisposeStatefulWidget> createState() =>
      _MissingDisposeStatefulWidgetState();
}

class _MissingDisposeStatefulWidgetState
    extends State<MissingDisposeStatefulWidget>
    with TickerProviderStateMixin {
  late TextEditingController _textControllerTest;
  late ScrollController _scrollController;
  late FocusNode _focusNode;
  late ValueNotifier<int> _valueNotifier;
  late final _focusNode2 = FocusNode();
  final _pageController = PageController();
  final _streamController = StreamController<String>();
  // expect_lint: avoid_missing_dispose
  final _streamController2 = StreamController<String>();
  late AnimationController _animationController;
  final _timer = Timer(Duration.zero, () {});
  final _timer2 = Timer(Duration.zero, () {});

  // expect_lint: avoid_missing_dispose
  var _notDisposedController = ScrollController();
  // expect_lint: avoid_missing_dispose
  late final _notDisposedController2 = FocusNode();
  // expect_lint: avoid_missing_dispose
  final _notDisposedController3 = ValueNotifier(0);
  // expect_lint: avoid_missing_dispose
  late final ScrollController _notDisposedController4;
  // expect_lint: avoid_missing_dispose
  late final FocusNode _notDisposedController5;
  // expect_lint: avoid_missing_dispose
  late final ValueNotifier<int> _notDisposedController6;
  // expect_lint: avoid_missing_dispose
  late final Timer _notDisposedTimer;

  late final AnimationController _ignoredInstance;

  @override
  void dispose() {
    _timer.cancel();
    _streamController.close();
    _textControllerTest.dispose();
    _scrollController.dispose();
    _valueNotifier.dispose();
    _focusNode.dispose();
    _focusNode2.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _disposeAnimationController() {
    _animationController.dispose();
  }

  void _disposeTimer() {
    _timer2.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final animationController2 = useAnimationController(
      duration: const Duration(seconds: 1),
    );
    return Column(
      children: [
        // expect_lint: avoid_missing_dispose
        TextField(controller: TextEditingController()),
        _buildTextField(),
        AnimatedBuilder(
          animation: animationController2,
          builder: (context, child) {
            return Container(
              color: Colors.red,
              height: animationController2.value,
            );
          },
        ),
      ],
    );
  }

  TextField _buildTextField() {
    // expect_lint: avoid_missing_dispose
    return TextField(controller: TextEditingController());
  }
}

class StatelessMissingDisposeWidget extends StatelessWidget {
  StatelessMissingDisposeWidget({
    super.key,
    required this.scrollController,
    required FocusNode focusNode,
  }) : _focusNode = focusNode;

  // expect_lint: avoid_missing_dispose
  final controller = TextEditingController();
  final ScrollController scrollController;
  final FocusNode _focusNode;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class RegularClass {
  final controller = TextEditingController();
}
