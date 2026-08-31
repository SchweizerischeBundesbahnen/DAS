import 'package:app_links_x/component.dart';

/// Base class for all app link intents used by DAS.
sealed class const AppLinkIntent(final Uri appLink);

/// Represents app link intent for train-journey page.
class const TrainJourneyIntent({
  required Uri appLink,
  required final List<TrainJourneyLinkData> journeys,
}) extends AppLinkIntent {
  this : super(appLink);
}
