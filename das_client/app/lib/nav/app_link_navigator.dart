import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:app/provider/user_settings.dart';
import 'package:app_links_x/component.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/component.dart';

final _log = Logger('AppLinkNavigator');

/// Handles navigation from app links provided by [AppLinksManager.onAppLinkIntent]
class AppLinkNavigator {
  AppLinkNavigator({
    required this._appLinksManager,
    required this._router,
  });

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
    if (!GetIt.I.isRegistered<SferaJourneyViewModel>()) {
      _log.info('Waiting for App to be ready');
      // If the App was not running when opening a deeplink, we need to give DI some time to register everything
      await Future.delayed(Duration(milliseconds: 500));
    }

    final journeys = intent.journeys;
    final (success, trainIdentifications) = await _resolveCompanies(journeys);
    if (!success) {
      _log.warning(
        'Not all companies could be resolved from deep-link (${trainIdentifications.length}/${journeys.length}',
      );
    }

    if (trainIdentifications.isEmpty) {
      _log.info('No Train identification could be resolved from deep-link, navigation to selection');
      if (!_router.isRouteActive(JourneySelectionRoute.name)) {
        _router.replace(JourneySelectionRoute());
      }

      if (journeys.isNotEmpty) {
        final selectionVM = DI.get<JourneySelectionViewModel>();
        selectionVM.handleDeepLink(intent.journeys.first);
      }
    } else {
      if (_router.isRouteActive(JourneyRoute.name)) {
        _log.info('Replacing journey navigation view model with new train identifications from deep-link');
        DI.get<JourneyNavigationViewModel>().replaceWith(trainIdentifications);
      } else {
        _log.info('Navigation to journey page with train identifications from deep-link');
        _router.replace(JourneyRoute(initialTrainIds: trainIdentifications));
      }
    }
  }

  /// Resolves the companies for the given [journeys] and returns a tuple of (success, resolvedTrainIdentifications).
  /// success is true if all companies could be resolved, false otherwise.
  /// The resolvedTrainIdentifications contains the successfully resolved train identifications.
  Future<(bool, List<ExtendedTrainIdentification>)> _resolveCompanies(List<TrainJourneyLinkData> journeys) async {
    final trainIdentificationRepository = DI.get<TrainIdentificationRepository>();
    final userSettings = DI.get<UserSettings>();
    final result = <ExtendedTrainIdentification>[];

    for (final journey in journeys) {
      if (journey.company != null) {
        final ru = RailwayUndertaking.fromCompanyCode(journey.company!);
        if (ru != RailwayUndertaking.unknown) {
          result.add(journey.toTrainIdentification(ru));
          continue;
        }
      } else {
        final companyMatches = await trainIdentificationRepository.findTrainIdentifications(
          operationalTrainNumber: journey.operationalTrainNumber,
        );
        final sameDayMatches = companyMatches.where(
          (it) => DateUtils.isSameDay(it.startDate, journey.startDate ?? DateTime.now()),
        );
        if (sameDayMatches.length == 1) {
          result.add(journey.toTrainIdentification(sameDayMatches.first.ru));
          continue;
        } else {
          final selectedRu = userSettings.lastUsedRailwayUndertaking;
          if (selectedRu != null) {
            final ruMatch = sameDayMatches.firstWhereOrNull((it) => it.ru == selectedRu);
            if (ruMatch != null) {
              result.add(journey.toTrainIdentification(ruMatch.ru));
              continue;
            }
          }
        }
      }
      return (false, result);
    }

    return (true, result);
  }

  void dispose() {
    _subscription?.cancel();
  }
}

extension _TrainJourneyLinkDataMapper on TrainJourneyLinkData {
  ExtendedTrainIdentification toTrainIdentification(RailwayUndertaking ru) {
    return ExtendedTrainIdentification(
      trainIdentification: TrainIdentification(
        trainNumber: operationalTrainNumber,
        ru: ru,
        date: startDate ?? DateTime.now(),
      ),
      tafTapLocationReferenceStart: tafTapLocationReferenceStart,
      tafTapLocationReferenceEnd: tafTapLocationReferenceEnd,
      returnUrl: returnUrl,
    );
  }
}
