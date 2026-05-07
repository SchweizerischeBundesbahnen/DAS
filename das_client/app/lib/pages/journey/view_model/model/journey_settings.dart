import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class JourneySettings {
  const JourneySettings({
    this.initialBrakeSeries,
    this.selectedBrakeSeries,
    this.expandedGroups = const [],
    this.journeyAdvancementModel = const Automatic(),
  });

  /// Initial BrakeSeries of journey. Use this instead of [Metadata.brakeSeries] as TC updates are ignored.
  final BrakeSeries? initialBrakeSeries;

  final BrakeSeries? selectedBrakeSeries;
  final List<int> expandedGroups;
  final JourneyAdvancementModel journeyAdvancementModel;

  JourneySettings copyWith({
    BrakeSeries? initialBrakeSeries,
    BrakeSeries? selectedBrakeSeries,
    List<int>? expandedGroups,
    JourneyAdvancementModel? journeyAdvancementModel,
  }) {
    return JourneySettings(
      initialBrakeSeries: initialBrakeSeries ?? this.initialBrakeSeries,
      selectedBrakeSeries: selectedBrakeSeries ?? this.selectedBrakeSeries,
      expandedGroups: expandedGroups ?? this.expandedGroups,
      journeyAdvancementModel: journeyAdvancementModel ?? this.journeyAdvancementModel,
    );
  }

  BrakeSeries? get currentBrakeSeries => selectedBrakeSeries ?? initialBrakeSeries;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneySettings &&
          runtimeType == other.runtimeType &&
          initialBrakeSeries == other.initialBrakeSeries &&
          selectedBrakeSeries == other.selectedBrakeSeries &&
          ListEquality().equals(expandedGroups, other.expandedGroups) &&
          journeyAdvancementModel == other.journeyAdvancementModel;

  @override
  int get hashCode =>
      initialBrakeSeries.hashCode ^
      selectedBrakeSeries.hashCode ^
      const ListEquality().hash(expandedGroups) ^
      journeyAdvancementModel.hashCode;
}
