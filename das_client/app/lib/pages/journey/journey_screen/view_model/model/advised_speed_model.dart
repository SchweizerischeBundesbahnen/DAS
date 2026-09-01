import 'package:sfera/component.dart';

sealed class const AdvisedSpeedModel._() {
  factory active({required AdvisedSpeedSegment segment, SingleSpeed? lineSpeed}) = Active;

  factory inactive() = Inactive;

  factory end() = End;

  factory cancel() = Cancel;

  @override
  bool operator ==(Object other) => identical(this, other) || runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class const Active({
  required final AdvisedSpeedSegment segment,
  final SingleSpeed? lineSpeed,
}) extends AdvisedSpeedModel {
  this : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Active && segment == other.segment && lineSpeed == other.lineSpeed);

  @override
  int get hashCode => Object.hash(runtimeType, segment, lineSpeed);
}

class const Inactive() extends AdvisedSpeedModel {
  this : super._();
}

class const End() extends AdvisedSpeedModel {
  this : super._();
}

class const Cancel() extends AdvisedSpeedModel {
  this : super._();
}
