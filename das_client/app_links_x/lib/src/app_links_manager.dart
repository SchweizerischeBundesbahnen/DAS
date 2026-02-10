import 'package:app_links_x/src/train_journey/train_journey_link_data.dart';

/// Processes all deep-links used to open DAS app.
///
/// see: [DAS deep-link documentation](https://github.com/SchweizerischeBundesbahnen/DAS/blob/main/docs/content/architecture/05_building_block_view/05_02_Interfaces/deep_link_client.md)
abstract interface class AppLinksManager {
  const AppLinksManager._();

  Stream<List<TrainJourneyLinkData>> get onTrainJourneyLink;
}
