import 'package:app/pages/journey/journey_table/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/chevron_animation_data.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/pages/journey/settings/journey_settings.dart';

/// Data class to hold all the information to visualize the train journey.
class JourneyConfig {
  const JourneyConfig({
    this.trackEquipmentRenderData,
    this.bracketStationRenderData,
    this.chevronAnimationData,
    this.settings = const JourneySettings(),
  });

  final JourneySettings settings;
  final TrackEquipmentRenderData? trackEquipmentRenderData;
  final BracketStationRenderData? bracketStationRenderData;
  final ChevronAnimationData? chevronAnimationData;
}
