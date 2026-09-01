import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app_links_x/component.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:train_identification/component.dart';

final _log = Logger('AppLinkNavigator');

/// Handles navigation from app links provided by [AppLinksManager.onAppLinkIntent]
class AppLinkNavigator({
  required final AppLinksManager _appLinksManager,
  required final AppRouter _router,
}) {
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
    final userSettings = DI.get<LocalKeyValueStore>();
    final result = <ExtendedTrainIdentification>[];

    for (final journey in journeys) {
      if (journey.company != null) {
        result.add(journey.toTrainIdentification(journey.company!));
      } else {
        final companyMatches = await trainIdentificationRepository.findTrainIdentifications(
          operationalTrainNumber: journey.operationalTrainNumber,
        );
        final sameDayMatches = companyMatches.where(
          (it) => DateUtils.isSameDay(it.startDate, journey.startDate ?? DateTime.now()),
        );
        if (sameDayMatches.length == 1) {
          result.add(journey.toTrainIdentification(sameDayMatches.first.companyCode));
          continue;
        } else {
          final selectedCompanyCode = userSettings.lastUsedCompanyCode;
          if (selectedCompanyCode != null) {
            final companyMatch = sameDayMatches.firstWhereOrNull((it) => it.companyCode == selectedCompanyCode);
            if (companyMatch != null) {
              result.add(journey.toTrainIdentification(companyMatch.companyCode));
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
  ExtendedTrainIdentification toTrainIdentification(String companyCode) {
    return ExtendedTrainIdentification(
      trainIdentification: TrainIdentification(
        trainNumber: operationalTrainNumber,
        companyCode: companyCode,
        date: startDate ?? DateTime.now(),
      ),
      tafTapLocationReferenceStart: tafTapLocationReferenceStart,
      tafTapLocationReferenceEnd: tafTapLocationReferenceEnd,
      returnUrl: returnUrl,
    );
  }
}
