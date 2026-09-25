import 'package:app/pages/journey/journey_screen/widgets/table/config/bracket_station_render_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/chevron_animation_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';

class const JourneyConfig({
  final TrackEquipmentRenderData? trackEquipmentRenderData,
  final BracketStationRenderData? bracketStationRenderData,
  final ChevronAnimationData? chevronAnimationData,
  final JourneySettings settings = const JourneySettings(),
  final bool showModification = true,
});
