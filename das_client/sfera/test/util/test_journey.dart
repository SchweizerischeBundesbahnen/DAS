import 'package:sfera/component.dart';

import 'test_journey_skeleton.dart';

/// Represents a journey from static test resources. Acts as a decorator to a [Journey].
class TestJourney {
  const TestJourney({required this.journey, required this.name, required this.skeleton, this.eventName});

  final Journey journey;
  final String name;
  final String? eventName;

  final TestJourneySkeleton skeleton;

  bool validate() => skeleton.validate();
}
