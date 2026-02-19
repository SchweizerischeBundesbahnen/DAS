import 'dart:async';

import 'package:app/nav/app_router.dart';
import 'package:app_links_x/component.dart';
import 'package:sfera/component.dart';

/// Handles navigation from app links provided by [AppLinksManager.onAppLinkIntent]
class AppLinkNavigator {
  AppLinkNavigator({
    required AppLinksManager appLinksManager,
    required AppRouter router,
  }) : _appLinksManager = appLinksManager,
       _router = router;

  final AppLinksManager _appLinksManager;
  final AppRouter _router;

  StreamSubscription<AppLinkIntent>? _subscription;

  void observe() {
    _subscription = _appLinksManager.onAppLinkIntent.listen((intent) => _handleIntent(intent));
  }

  Future<void> _handleIntent(AppLinkIntent intent) async {
    switch (intent) {
      case TrainJourneyIntent():
        await _handleTrainJourneyIntent(intent);
        break;
    }
  }

  Future<void> _handleTrainJourneyIntent(TrainJourneyIntent intent) async {
    final trainIdentifications = intent.journeys.map((journey) => journey.toTrainIdentification());
    _router.replace(JourneyRoute(initialTrainIds: trainIdentifications.toList()));
  }

  void dispose() {
    _subscription?.cancel();
  }
}

extension _TrainJourneyLinkDataMapper on TrainJourneyLinkData {
  TrainIdentification toTrainIdentification() {
    // TODO: resolve company as soon as train number API / preload is finished or change company to required param in deep link.
    final railwayUndertaking = company != null ? RailwayUndertaking.fromCompanyCode(company!) : RailwayUndertaking.sbbP;
    return TrainIdentification(
      trainNumber: operationalTrainNumber,
      ru: railwayUndertaking,
      date: startDate ?? DateTime.now(),
      tafTapLocationReferenceStart: tafTapLocationReferenceStart,
      tafTapLocationReferenceEnd: tafTapLocationReferenceEnd,
    );
  }
}
