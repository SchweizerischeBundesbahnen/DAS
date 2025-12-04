import 'dart:math';

import 'package:sfera/component.dart';

class DraftAdvisedSpeedSegment implements Comparable<DraftAdvisedSpeedSegment> {
  DraftAdvisedSpeedSegment({
    required this.type,
    required int previousSegmentEndOrder,
    required int nextSegmentStartOrder,
    this.speed,
    int? startOrder,
    int? endOrder,
  }) : _startOrder = startOrder,
       _endOrder = endOrder,
       _nextSegmentStartOrder = nextSegmentStartOrder,
       _previousSegmentEndOrder = previousSegmentEndOrder;

  int? _startOrder;
  int? _endOrder;

  final int _previousSegmentEndOrder;
  final int _nextSegmentStartOrder;

  final DraftAdvisedSpeedType type;

  final SingleSpeed? speed;

  bool _isStartAmended = false;
  bool _isEndAmended = false;

  bool get startsWithSegment => _startOrder == null;

  bool get endsWithSegment => _endOrder == null;

  bool get isStartAmended => _isStartAmended;

  bool get isEndAmended => _isEndAmended;

  BaseData? endData;

  set startOrder(int value) {
    _startOrder = value;
    _isStartAmended = true;
  }

  set endOrder(int value) {
    _endOrder = value;
    _isEndAmended = true;
  }

  int get startOrder => _startOrder ?? _previousSegmentEndOrder;

  int get endOrder => _endOrder ?? _nextSegmentStartOrder;

  int get advisedSpeedGroupKey => Object.hash(speed, type);

  bool get isValid => endOrder > startOrder && endsWithSegment == false && startsWithSegment == false;

  @override
  String toString() {
    return 'DraftAdvisedSpeedSegment{'
        'startOrder: $_startOrder, '
        'endOrder: $_endOrder, '
        'previousSegmentEndOrder: $_previousSegmentEndOrder, '
        'nextSegmentStartOrder: $_nextSegmentStartOrder, '
        'type: $type, '
        'speed: $speed, '
        'isStartAmended: $_isStartAmended, '
        'isEndAmended: $_isEndAmended, '
        'endData: $endData'
        '}';
  }

  @override
  int compareTo(DraftAdvisedSpeedSegment other) => startOrder.compareTo(other.startOrder);

  DraftAdvisedSpeedSegment merge(DraftAdvisedSpeedSegment other) {
    return DraftAdvisedSpeedSegment(
      type: type,
      previousSegmentEndOrder: min(_previousSegmentEndOrder, other._previousSegmentEndOrder),
      nextSegmentStartOrder: max(_nextSegmentStartOrder, other._nextSegmentStartOrder),
      speed: speed,
      startOrder: _mergeOrder(_startOrder, other._startOrder, min),
      endOrder: _mergeOrder(_endOrder, other._endOrder, max),
    );
  }

  int? _mergeOrder(int? order, int? otherOrder, T Function<T extends num>(T a, T b) func) {
    if (order != null && otherOrder != null) return func(order, otherOrder);
    if (order == null && otherOrder == null) return null;
    return order ?? otherOrder;
  }

  AdvisedSpeedSegment toAdvisedSegment() {
    if (endData == null) throw FormatException('Cannot map to advisedSegment without having endData set!');
    return switch (type) {
      .velocityMax => VelocityMaxAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        endData: endData!,
        isEndDataCalculated: isEndAmended,
      ),
      .followTrain => FollowTrainAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        speed: speed!,
        endData: endData!,
        isEndDataCalculated: isEndAmended,
      ),
      .trainFollowing => TrainFollowingAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        speed: speed!,
        endData: endData!,
        isEndDataCalculated: isEndAmended,
      ),
      .fixedTime => FixedTimeAdvisedSpeedSegment(
        startOrder: startOrder,
        endOrder: endOrder,
        speed: speed!,
        endData: endData!,
        isEndDataCalculated: isEndAmended,
      ),
    };
  }
}

enum DraftAdvisedSpeedType {
  velocityMax,
  followTrain,
  trainFollowing,
  fixedTime,
}
