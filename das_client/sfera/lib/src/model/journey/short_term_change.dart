import 'package:sfera/component.dart';

/// Short to medium term changes before journey departure (< 27h before journey departure).
sealed class ShortTermChange extends Segment {
  const ShortTermChange({
    required int startOrder,
    required int endOrder,
    required this.startData,
  }) : super(startOrder: startOrder, endOrder: endOrder);

  final BaseData startData;

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
        'startData: $startData}'
        ', startOrder: $startOrder'
        ', endOrder: $endOrder'
        '}';
  }
}

class Stop2PassChange extends ShortTermChange {
  const Stop2PassChange({required super.startOrder, required super.endOrder, required super.startData});
}

class Pass2StopChange extends ShortTermChange {
  const Pass2StopChange({required super.startOrder, required super.endOrder, required super.startData});
}

class TrainRunReroutingChange extends ShortTermChange {
  const TrainRunReroutingChange({required super.startOrder, required super.endOrder, required super.startData});
}

class EndDestinationChange extends ShortTermChange {
  const EndDestinationChange({required super.startOrder, required super.endOrder, required super.startData});
}
