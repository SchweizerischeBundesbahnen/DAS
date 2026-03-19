import 'dart:async';

import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app_links_x/component.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';

final _log = Logger('AppLinkNavigator');

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
    if (!GetIt.I.isRegistered<JourneyViewModel>()) {
      _log.info('Waiting for App to be ready');
      // If the App was not running when opening a deeplink, we need to give DI some time to register everything
      await Future.delayed(Duration(milliseconds: 500));
    }

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
      returnUrl: returnUrl,
    );
  }
}
