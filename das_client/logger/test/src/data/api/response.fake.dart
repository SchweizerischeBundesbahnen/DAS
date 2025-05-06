import 'package:http_x/component.dart';
import 'package:mockito/mockito.dart';

class FakeResponse extends Fake implements Response {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final Request request;

  FakeResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.request,
  });
}
