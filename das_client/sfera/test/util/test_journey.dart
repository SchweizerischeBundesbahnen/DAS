import 'package:sfera/component.dart';

/// Represents a journey from static test resources. Acts as a decorator to a [Journey].
class TestJourney {
  const TestJourney({required this.journey, required this.name, this.eventName});

  final Journey journey;
  final String name;
  final String? eventName;
}
