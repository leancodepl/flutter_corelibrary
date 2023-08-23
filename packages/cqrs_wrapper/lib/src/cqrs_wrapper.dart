// ignore_for_file: public_member_api_docs

import 'package:cqrs/cqrs.dart';
import 'package:logging/logging.dart';

class CqrsWrapper {
  const CqrsWrapper({
    required Cqrs cqrs,
    required Logger logger,
  })  : _cqrs = cqrs,
        _logger = logger;

  final Cqrs _cqrs;
  final Logger _logger;
}
