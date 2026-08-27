import 'package:sfera/component.dart';

/// Short to medium term changes before journey departure (< 27h before journey departure).
sealed class const ShortTermChange({
  required super.startOrder,
  required super.endOrder,
  required final ServicePoint startData,
}) extends Segment {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShortTermChange &&
            other.runtimeType == runtimeType &&
            startOrder == other.startOrder &&
            endOrder == other.endOrder &&
            startData == other.startData;
  }

  @override
  int get hashCode => Object.hash(startOrder, endOrder, startData);

  @override
  String toString() {
    return 'ShortTermChange{'
        'startData: $startData'
        ', startOrder: $startOrder'
        ', endOrder: $endOrder'
        '}';
  }
}

class const StopToPassChange({required super.startOrder, required super.endOrder, required super.startData})
    extends ShortTermChange;

class const PassToStopChange({required super.startOrder, required super.endOrder, required super.startData})
    extends ShortTermChange;

class const TrainRunReroutingChange({required super.startOrder, required super.endOrder, required super.startData})
    extends ShortTermChange;

class const EndDestinationChange({required super.startOrder, required super.endOrder, required super.startData})
    extends ShortTermChange;
