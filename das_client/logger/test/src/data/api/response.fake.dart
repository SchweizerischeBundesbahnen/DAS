import 'package:http_x/component.dart';
import 'package:mockito/mockito.dart';

class FakeResponse({
  required final int statusCode,
  required final Map<String, String> headers,
  required final String body,
  required final Request request,
}) extends Fake implements Response;
