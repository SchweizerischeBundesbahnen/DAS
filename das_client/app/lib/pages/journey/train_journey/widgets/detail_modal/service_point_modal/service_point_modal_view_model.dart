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
  final _rxMetadata = BehaviorSubject<Metadata>();
  final _rxServicePoint = BehaviorSubject<ServicePoint>();
  final _rxSelectedTab = BehaviorSubject.seeded(ServicePointModalTab.values.first);
  final _rxSettings = BehaviorSubject<TrainJourneySettings>();
  final _rxRelevantSpeedInfo = BehaviorSubject.seeded(<Speeds>[]);
  final _rxBreakSeries = BehaviorSubject<BreakSeries?>();
  final _subscriptions = <StreamSubscription>[];

  Stream<ServicePointModalTab> get selectedTab => _rxSelectedTab.distinct();

  Stream<ServicePoint> get servicePoint => _rxServicePoint.distinct();

  Stream<RadioContactList?> get radioContacts => _rxRadioContactList.distinct();

  Stream<CommunicationNetworkType?> get communicationNetworkType => _rxCommunicationNetworkType.distinct();

  Stream<List<Speeds>> get relevantSpeedInfo => _rxRelevantSpeedInfo.distinct();

  Stream<BreakSeries?> get breakSeries => _rxBreakSeries.distinct();

  void _init() {
    _initRadioContacts();
    _initCommunicationNetworkType();
    _initRelevantSpeedInfo();
  }

  void _initRadioContacts() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) => metadata.radioContactLists.lastLowerThan(servicePoint.order),
    ).listen(_rxRadioContactList.add, onError: _rxRadioContactList.addError);
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
  }
}
