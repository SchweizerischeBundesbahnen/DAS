import 'package:sfera/component.dart';

sealed class AdaptiveSteeringModel {
  const AdaptiveSteeringModel._();

  factory AdaptiveSteeringModel.active({required AdvisedSpeedSegment segment}) = Active;

  factory AdaptiveSteeringModel.inactive() = Inactive;

  factory AdaptiveSteeringModel.end() = End;

  factory AdaptiveSteeringModel.cancel() = Cancel;
}

class Active extends AdaptiveSteeringModel {
  const Active({required this.segment}) : super._();
  final AdvisedSpeedSegment segment;
}

class Inactive extends AdaptiveSteeringModel {
  const Inactive() : super._();
}

class End extends AdaptiveSteeringModel {
  const End() : super._();
}

class Cancel extends AdaptiveSteeringModel {
  const Cancel() : super._();
}
