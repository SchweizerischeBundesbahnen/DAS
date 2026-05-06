import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:flutter/material.dart';
import 'package:local_regulations/component.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ServicePointModalViewModel extends JourneyAwareViewModel {
  ServicePointModalViewModel({
    required LocalRegulationHtmlGenerator localRegulationHtmlGenerator,
    required JourneySettingsViewModel settingsVM,
    required super.journeyViewModel,
  }) : _localRegulationHtmlGenerator = localRegulationHtmlGenerator,
       _settingsVM = settingsVM {
    _init();
  }

  final LocalRegulationHtmlGenerator _localRegulationHtmlGenerator;
  final JourneySettingsViewModel _settingsVM;

  final _rxCommunicationNetworkType = BehaviorSubject<CommunicationNetworkType?>();
  final _rxRadioContactList = BehaviorSubject<RadioContactList?>();
  final _rxSimCorridor = BehaviorSubject<RadioContactList?>();
  final _rxDepartureAuth = BehaviorSubject<DepartureAuthorization?>();
  final _rxMetadata = BehaviorSubject<Metadata>();
  final _rxServicePoint = BehaviorSubject<ServicePoint>();
  final _rxSelectedTab = BehaviorSubject<ServicePointModalTab?>();
  final _rxSettings = BehaviorSubject<JourneySettings>();
  final _rxRelevantSpeedInfo = BehaviorSubject.seeded(<TrainSeriesSpeed>[]);
  final _rxLocalRegulationSections = BehaviorSubject.seeded(<LocalRegulationSection>[]);
  final _rxLocalRegulationHtml = BehaviorSubject<String>();
  final _rxBrakeSeries = BehaviorSubject<BrakeSeries?>();
  final _rxTabs = BehaviorSubject.seeded(<ServicePointModalTab>[]);
  final _subscriptions = <StreamSubscription>[];

  ServicePointModalTab? get selectedTabValue => _rxSelectedTab.valueOrNull;

  Stream<ServicePointModalTab?> get selectedTab => _rxSelectedTab.distinct();

  Stream<ServicePoint> get servicePoint => _rxServicePoint.distinct();

  Stream<RadioContactList?> get radioContacts => _rxRadioContactList.distinct();

  Stream<RadioContactList?> get simCorridor => _rxSimCorridor.distinct();

  Stream<CommunicationNetworkType?> get communicationNetworkType => _rxCommunicationNetworkType.distinct();

  Stream<List<TrainSeriesSpeed>> get relevantSpeedInfo => _rxRelevantSpeedInfo.distinct();

  Stream<BrakeSeries?> get brakeSeries => _rxBrakeSeries.distinct();

  Stream<List<ServicePointModalTab>> get tabs => _rxTabs.distinct();

  Stream<String> get localRegulationHtml => _rxLocalRegulationHtml.distinct();

  Stream<DepartureAuthorization?> get departureAuthorization => _rxDepartureAuth.distinct();

  void _init() {
    _initSettingsSubscription();
    _initRadioContacts();
    _initSimCorridor();
    _initCommunicationNetworkType();
    _initRelevantSpeedInfo();
    _initTabs();
    _initSelectedTab();
    _initLocalRegulationSection();
    _initLocalRegulationHtml();
    _initDepartureAuth();
  }

  void _initRadioContacts() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) =>
          metadata.radioContactLists.where((it) => !it.isSimCorridor).lastBefore(servicePoint.order),
    ).listen(_rxRadioContactList.add, onError: _rxRadioContactList.addError);
    _subscriptions.add(subscription);
  }

  void _initSimCorridor() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) => metadata.radioContactLists
          .where(
            (it) => it.isSimCorridor && it.order <= servicePoint.order && it.endOrder >= servicePoint.order,
          )
          .firstOrNull,
    ).listen(_rxSimCorridor.add, onError: _rxSimCorridor.addError);
    _subscriptions.add(subscription);
  }

  void _initRelevantSpeedInfo() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxSettings.stream,
      (servicePoint, settings) {
        final currentBrakeSeries = settings.currentBrakeSeries;
        _rxBrakeSeries.add(currentBrakeSeries);

        return servicePoint.relevantGraduatedSpeedInfo(currentBrakeSeries);
      },
    ).listen(_rxRelevantSpeedInfo.add, onError: _rxRelevantSpeedInfo.addError);
    _subscriptions.add(subscription);
  }

  void _initCommunicationNetworkType() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) => metadata.communicationNetworkChanges.typeByLastBefore(servicePoint.order),
    ).listen(_rxCommunicationNetworkType.add, onError: _rxCommunicationNetworkType.addError);
    _subscriptions.add(subscription);
  }

  void _initTabs() {
    final subscription = Rx.combineLatest3(
      _rxBrakeSeries.stream,
      _rxRelevantSpeedInfo.stream,
      _rxLocalRegulationSections.stream,
      (brakeSeries, relevantSpeedData, localRegulations) {
        final tabsWithData = <ServicePointModalTab>[.communication];
        if (brakeSeries != null && relevantSpeedData.isNotEmpty) {
          tabsWithData.add(.graduatedSpeeds);
        }

        if (localRegulations.isNotEmpty) {
          tabsWithData.add(.localRegulations);
        }

        return tabsWithData;
      },
    ).listen(_rxTabs.add, onError: _rxTabs.addError);
    _subscriptions.add(subscription);
  }

  void _initSelectedTab() {
    final subscription = _rxTabs.listen((tabs) {
      if (_rxSelectedTab.valueOrNull == null && tabs.isNotEmpty) {
        _rxSelectedTab.add(tabs.first);
      }
    });
    _subscriptions.add(subscription);
  }

  void _initLocalRegulationSection() {
    final subscription = _rxServicePoint
        .map((servicePoint) => servicePoint.localRegulationSections)
        .listen(_rxLocalRegulationSections.add, onError: _rxLocalRegulationSections.addError);
    _subscriptions.add(subscription);
  }

  void _initLocalRegulationHtml() {
    final subscription = _rxLocalRegulationSections
        .asyncMap((sections) => _localRegulationHtmlGenerator.generate(sections: sections))
        .listen(_rxLocalRegulationHtml.add, onError: _rxLocalRegulationHtml.addError);
    _subscriptions.add(subscription);
  }

  void _initDepartureAuth() {
    final subscription = _rxServicePoint
        .map((servicePoint) => servicePoint.departureAuthorization)
        .listen(_rxDepartureAuth.add, onError: _rxDepartureAuth.addError);
    _subscriptions.add(subscription);
  }

  void open(BuildContext context, {ServicePointModalTab? tab, ServicePoint? servicePoint}) {
    if (tab != null) {
      _rxSelectedTab.add(tab);
    }
    if (servicePoint != null) {
      _rxServicePoint.add(servicePoint);
    }

    final viewModel = context.read<DetailModalViewModel>();
    final openAsMaximized = tab == .localRegulations;
    viewModel.open(ServicePointModalBuilder(), maximize: openAsMaximized);
  }

  void close(BuildContext context) => context.read<DetailModalViewModel>().close();

  @override
  void journeyUpdated(Journey? journey) {
    if (journey != null) _rxMetadata.add(journey.metadata);

    super.journeyUpdated(journey);
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    if (journey != null) _rxMetadata.add(journey.metadata);
    if (lastJourney != null) {
      _cancelSubscriptions();
      _init();
    }
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _rxMetadata.close();
    _rxSelectedTab.close();
    _rxCommunicationNetworkType.close();
    _rxServicePoint.close();
    _rxSettings.close();
    _rxRelevantSpeedInfo.close();
    _rxBrakeSeries.close();
    _rxLocalRegulationSections.close();
    _rxLocalRegulationHtml.close();
    _rxTabs.close();
    _rxDepartureAuth.close();
    super.dispose();
  }

  void _cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  void _initSettingsSubscription() {
    final subscription = _settingsVM.model.listen(_rxSettings.add);
    _subscriptions.add(subscription);
  }
}
