import 'dart:async';

import 'package:leancode_common/leancode_common.dart';

import 'models/token.dart';

class LoginState implements Disposable {
  LoginState()
      : _currentToken = null,
        _controller = StreamController.broadcast();

  final StreamController<bool> _controller;

  Token _currentToken;
  Token get currenToken => _currentToken;

  bool get isLoggedIn => _currentToken != null;

  Stream<bool> get onLoggedInChange => _controller.stream;

  void setToken(Token token) {
    final previousIsLoggedIn = isLoggedIn;

    _currentToken = token;

    final currentIsLoggedIn = _currentToken != null;
    if (currentIsLoggedIn != previousIsLoggedIn) {
      _controller.add(currentIsLoggedIn);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
