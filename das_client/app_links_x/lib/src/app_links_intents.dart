import 'package:app_links_x/component.dart';

/// TODO: Docs
sealed class AppLinkIntent {
  const AppLinkIntent(this.source);

  final Uri source;

  bool get requiresAuth;
}

/// TODO: Docs
class TrainJourneyIntent extends AppLinkIntent {
  const TrainJourneyIntent({required Uri source, required this.journeys}) : super(source);

  final List<TrainJourneyLinkData> journeys;

  @override
  bool get requiresAuth => true;
}
