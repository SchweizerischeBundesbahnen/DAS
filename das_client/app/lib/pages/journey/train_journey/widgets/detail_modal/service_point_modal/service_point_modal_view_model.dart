import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ServicePointModalViewModel {
  ServicePointModalViewModel() {
    _init();
  }

  final _rxCommunicationNetworkType = BehaviorSubject<CommunicationNetworkType?>();
  final _rxRadioContactList = BehaviorSubject<RadioContactList?>();
  final _rxSimCorridor = BehaviorSubject<RadioContactList?>();
  final _rxMetadata = BehaviorSubject<Metadata>();
  final _rxServicePoint = BehaviorSubject<ServicePoint>();
  final _rxSelectedTab = BehaviorSubject<ServicePointModalTab?>();
  final _rxSettings = BehaviorSubject<TrainJourneySettings>();
  final _rxRelevantSpeedInfo = BehaviorSubject.seeded(<TrainSeriesSpeed>[]);
  final _rxBreakSeries = BehaviorSubject<BreakSeries?>();
  final _rxTabs = BehaviorSubject.seeded(<ServicePointModalTab>[]);
  final _subscriptions = <StreamSubscription>[];

  Stream<ServicePointModalTab?> get selectedTab => _rxSelectedTab.distinct();

  Stream<ServicePoint> get servicePoint => _rxServicePoint.distinct();

  Stream<RadioContactList?> get radioContacts => _rxRadioContactList.distinct();

  Stream<RadioContactList?> get simCorridor => _rxSimCorridor.distinct();

  Stream<CommunicationNetworkType?> get communicationNetworkType => _rxCommunicationNetworkType.distinct();

  Stream<List<TrainSeriesSpeed>> get relevantSpeedInfo => _rxRelevantSpeedInfo.distinct();

  Stream<BreakSeries?> get breakSeries => _rxBreakSeries.distinct();

  Stream<List<ServicePointModalTab>> get tabs => _rxTabs.distinct();

  void _init() {
    _initRadioContacts();
    _initSimCorridor();
    _initCommunicationNetworkType();
    _initRelevantSpeedInfo();
    _initTabs();
    _initSelectedTab();
  }

  void _initRadioContacts() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) =>
          metadata.radioContactLists.where((it) => !it.isSimCorridor).lastLowerThan(servicePoint.order),
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
    final subscription = Rx.combineLatest3(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      _rxSettings.stream,
      (servicePoint, metadata, settings) {
        final currentBreakSeries = settings.resolvedBreakSeries(metadata);
        _rxBreakSeries.add(currentBreakSeries);

        return servicePoint.relevantGraduatedSpeedInfo(currentBreakSeries);
      },
    ).listen(_rxRelevantSpeedInfo.add, onError: _rxRelevantSpeedInfo.addError);
    _subscriptions.add(subscription);
  }

  void _initCommunicationNetworkType() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) => metadata.communicationNetworkChanges.whereNotSim.appliesToOrder(servicePoint.order),
    ).listen(_rxCommunicationNetworkType.add, onError: _rxCommunicationNetworkType.addError);
    _subscriptions.add(subscription);
  }

  void _initTabs() {
    final subscription = Rx.combineLatest2(
      _rxBreakSeries.stream,
      _rxRelevantSpeedInfo.stream,
      (breakSeries, relevantSpeedData) {
        final tabsWithData = <ServicePointModalTab>[ServicePointModalTab.communication];
        if (breakSeries != null && relevantSpeedData.isNotEmpty) {
          tabsWithData.add(ServicePointModalTab.graduatedSpeeds);
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

  void updateMetadata(Metadata metadata) => _rxMetadata.add(metadata);

  void updateSettings(TrainJourneySettings settings) => _rxSettings.add(settings);

  void open(BuildContext context, {ServicePointModalTab? tab, ServicePoint? servicePoint}) {
    if (tab != null) {
      _rxSelectedTab.add(tab);
    }
    if (servicePoint != null) {
      _rxServicePoint.add(servicePoint);
    }

    final viewModel = context.read<DetailModalViewModel>();
    final openAsMaximized = tab == ServicePointModalTab.localRegulations;
    viewModel.open(ServicePointModalBuilder(), maximize: openAsMaximized);
  }

  void close(BuildContext context) => context.read<DetailModalViewModel>().close();

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _rxMetadata.close();
    _rxSelectedTab.close();
    _rxCommunicationNetworkType.close();
    _rxServicePoint.close();
    _rxSettings.close();
    _rxRelevantSpeedInfo.close();
    _rxBreakSeries.close();
    _rxTabs.close();
  }
}
