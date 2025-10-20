import 'package:sfera/component.dart';

sealed class AdvisedSpeedModel {
  const AdvisedSpeedModel._();

  factory AdvisedSpeedModel.active({required AdvisedSpeedSegment segment}) = Active;

  factory AdvisedSpeedModel.inactive() = Inactive;

  factory AdvisedSpeedModel.end() = End;

  factory AdvisedSpeedModel.cancel() = Cancel;
}

class Active extends AdvisedSpeedModel {
  const Active({required this.segment}) : super._();
  final AdvisedSpeedSegment segment;
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
