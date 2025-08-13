import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
abstract class JourneyAnnotation extends BaseData {
  const JourneyAnnotation({
    required super.type,
    required super.order,
  });
}
