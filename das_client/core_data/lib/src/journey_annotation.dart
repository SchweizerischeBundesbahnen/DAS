import 'package:core_data/component.dart';
import 'package:meta/meta.dart';

@immutable
abstract class JourneyAnnotation extends BaseData {
  const JourneyAnnotation({
    required super.dataType,
    required super.order,
  });
}
