import 'dart:convert';
import 'package:http/http.dart';

final successResponse = Response(
    json.encode({
      'access_token': 'asd',
      'refresh_token': 'fgh',
      'token_type': 'Bearer',
    }),
    200,
    headers: {'content-type': 'application/json'});

final invalidGrantResponse = Response(
    json.encode({'error': 'invalid_grant'}), 400,
    headers: {'content-type': 'application/json'});

final invalidClientResponse = Response(
    json.encode({'error': 'invalid_client'}), 400,
    headers: {'content-type': 'application/json'});
