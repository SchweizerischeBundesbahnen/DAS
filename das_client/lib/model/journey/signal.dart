import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

class Signal extends BaseData {
  Signal({
    required super.order,
    required super.kilometre,
    this.visualIdentifier,
    this.functions = const [],
  }) : super(type: Datatype.signal);

  final List<SignalFunction> functions;
  final String? visualIdentifier;
}

enum SignalFunction {
  entry,
  exit,
  intermediate,
  block,
  protection,
  laneChange,
  unknown;

  factory SignalFunction.from(String value) {
    return values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SignalFunction.unknown,
    );
  }
}