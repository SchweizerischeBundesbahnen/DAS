import 'package:app/pages/journey/train_journey/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/chevron_animation_data.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';

/// Data class to hold all the information to visualize the train journey.
class TrainJourneyConfig {
  const TrainJourneyConfig({
    this.trackEquipmentRenderData,
    this.bracketStationRenderData,
    this.chevronAnimationData,
    this.settings = const TrainJourneySettings(),
  });

  final TrainJourneySettings settings;
  final TrackEquipmentRenderData? trackEquipmentRenderData;
  final BracketStationRenderData? bracketStationRenderData;
  final ChevronAnimationData? chevronAnimationData;
}
