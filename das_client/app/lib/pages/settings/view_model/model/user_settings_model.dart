import 'package:app/model/tour_system.dart';
import 'package:collection/collection.dart';

class const UserSettingsModel({
  final List<String> companyCodes = const [],
  final TourSystem? tourSystem,
  final bool showDecisiveGradient = true,
  final bool showStationSignals = true,
  final bool showEctsConventionalSpeedSignals = true,
  final bool showEctsExtendedSpeedSignals = true,
}) {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsModel &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(companyCodes, other.companyCodes) &&
          tourSystem == other.tourSystem &&
          showDecisiveGradient == other.showDecisiveGradient &&
          showStationSignals == other.showStationSignals &&
          showEctsConventionalSpeedSignals == other.showEctsConventionalSpeedSignals &&
          showEctsExtendedSpeedSignals == other.showEctsExtendedSpeedSignals;

  @override
  int get hashCode =>
      const ListEquality().hash(companyCodes) ^
      tourSystem.hashCode ^
      showDecisiveGradient.hashCode ^
      showStationSignals.hashCode ^
      showEctsConventionalSpeedSignals.hashCode ^
      showEctsExtendedSpeedSignals.hashCode;
}
