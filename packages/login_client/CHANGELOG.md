## [0.6.0] - 19.06.2020
Refactor login behavior
Extract grant details to AuthStrategy implementations

## [0.5.0] - 7.04.2020

Upgrade packages

## [0.4.3] - 30.10.2019

Include expiration field in token model

## [0.4.2] - 29.10.2019

Add assertion and sms token authentication

## [0.4.1] - 25.10.2019

Export models

## [0.4.0] - 25.10.2019

Reimplement authentication

`leancode_login_manager` has been replaced with `leancode_login_client`.
Right now it only supports logging in with credentials.

## [0.3.4] - 22.10.2019

Fix: Base login manager - initialize client from http library when there is no token.

## [0.3.3] - 22.10.2019

Fix: Export login result enum

## [0.3.2] - 22.10.2019

Fix: Add rxdart and flutter_test dependencies

## [0.3.1] - 16.10.2019

Fix: now grant handlers use client from their login manager instance

Tests: added simple result tests

## [0.3.0] - 16.10.2019

Breaking change: Grant handlers now return LoginResult instances instead of simple boolean value.

Fix: isLoggedIn value was null when error was added into the stream. Now errors never happen there and unhandled exceptions are being rethrown.

## [0.2.4] - 27.09.2019

Fix: handle only unauthrized requests

## [0.2.3] - 20.09.2019

Fix: handling requests during token refresh

## [0.2.2] - 9.09.2019

Fix: regression with logout on every request

## [0.2.1] - 4.09.2019

_DO NOT USE THIS VERSION, IT HAS A SEVERE REGRESSION_

Fix: wrongly released mutex on multiple refresh requests

## [0.2.0]

Initial release
