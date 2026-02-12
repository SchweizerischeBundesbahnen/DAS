import 'package:app_links_x/component.dart';

/// Base class for all app link intents used by DAS.
sealed class AppLinkIntent {
  const AppLinkIntent(this.source);

  final Uri source;
}

/// Represents app link intent for train-journey page.
class TrainJourneyIntent extends AppLinkIntent {
  const TrainJourneyIntent({required Uri source, required this.journeys}) : super(source);

  final List<TrainJourneyLinkData> journeys;
}
