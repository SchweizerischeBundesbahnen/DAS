import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/ux_testing_event.dart';

/// Flavor-extended repository contract for builds that enable UX testing
abstract class SferaFlavorRepository implements SferaRepository {
  /// UX-testing events parsed from NetworkSpecificEvents.
  Stream<UxTestingEvent?> get uxTestingEventStream;
}
