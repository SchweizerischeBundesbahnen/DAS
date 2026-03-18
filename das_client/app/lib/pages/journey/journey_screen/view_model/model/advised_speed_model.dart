import 'package:sfera/component.dart';

sealed class AdvisedSpeedModel {
  const AdvisedSpeedModel._();

  factory AdvisedSpeedModel.active({required AdvisedSpeedSegment segment, SingleSpeed? lineSpeed}) = Active;

  factory AdvisedSpeedModel.inactive() = Inactive;

  factory AdvisedSpeedModel.end() = End;

  factory AdvisedSpeedModel.cancel() = Cancel;

  @override
  bool operator ==(Object other) => identical(this, other) || runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class Active extends AdvisedSpeedModel {
  const Active({required this.segment, this.lineSpeed}) : super._();
  final AdvisedSpeedSegment segment;
  final SingleSpeed? lineSpeed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Active && segment == other.segment && lineSpeed == other.lineSpeed);

  @override
  int get hashCode => Object.hash(runtimeType, segment, lineSpeed);
}

class Inactive extends AdvisedSpeedModel {
  const Inactive() : super._();
}

class End extends AdvisedSpeedModel {
  const End() : super._();
}

class Cancel extends AdvisedSpeedModel {
  const Cancel() : super._();
}
