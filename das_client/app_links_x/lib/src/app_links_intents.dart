import 'package:app_links_x/component.dart';

/// Base class for all app link intents used by DAS.
sealed class AppLinkIntent {
  const AppLinkIntent(this.appLink);

  final Uri appLink;
}

/// Represents app link intent for train-journey page.
class TrainJourneyIntent extends AppLinkIntent {
  const TrainJourneyIntent({required Uri appLink, required this.journeys}) : super(appLink);

  final List<TrainJourneyLinkData> journeys;
}
