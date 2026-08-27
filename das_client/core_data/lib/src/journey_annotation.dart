import 'package:core_data/component.dart';
import 'package:meta/meta.dart';

@immutable
abstract class const JourneyAnnotation({
  required super.dataType,
  required super.order,
}) extends BaseData;
