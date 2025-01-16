import 'package:das_client/app/pages/journey/train_journey/widgets/table/render_data/bracket_station_render_data.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/render_data/track_equipment_render_data.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/render_data/train_journey_settings.dart';

/// Data class to hold all the information to visualize the train journey.
class TrainJourneyRenderData {
  const TrainJourneyRenderData({
    this.trackEquipmentRenderData = const TrackEquipmentRenderData(),
    this.settings = const TrainJourneySettings(),
    this.bracketStationRenderData = const BracketStationRenderData(),
  });

  final TrainJourneySettings settings;
  final TrackEquipmentRenderData trackEquipmentRenderData;
  final BracketStationRenderData bracketStationRenderData;
}
