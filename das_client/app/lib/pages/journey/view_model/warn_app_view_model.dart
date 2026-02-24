import 'dart:async';
import 'dart:io';

import 'package:app/flavor.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:appcheck/appcheck.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:warnapp/component.dart';

final _log = Logger('WarnAppViewModel');

class WarnAppViewModel {
  WarnAppViewModel({
    required this.flavor,
    required SferaRepository sferaRepo,
    required WarnappRepository warnappRepo,
    required RuFeatureProvider ruFeatureProvider,
    required NotificationPriorityQueueViewModel notificationViewModel,
  }) : _sferaRepo = sferaRepo,
       _warnappRepo = warnappRepo,
       _ruFeatureProvider = ruFeatureProvider,
       _notificationViewModel = notificationViewModel,
       _appCheck = AppCheck() {
    _init();
  }

  static const _warnappWindowMilliseconds = 1250;

  final Flavor flavor;

  final SferaRepository _sferaRepo;
  final WarnappRepository _warnappRepo;
  final RuFeatureProvider _ruFeatureProvider;
  final NotificationPriorityQueueViewModel _notificationViewModel;

  final AppCheck _appCheck;

  Stream<WarnappEvent> get warnappEvents => _rxWarnapp.stream;

  Future<bool> get isWarnappFeatureEnabled => _ruFeatureProvider.isRuFeatureEnabled(.warnapp);

  Stream<bool> get isManeuverModeEnabled => _rxManeuverModeEnabled.distinct();

  final _rxWarnapp = PublishSubject<WarnappEvent>();
  final _rxManeuverModeEnabled = BehaviorSubject.seeded(false);

  DateTime? _lastWarnappEventTimestamp;

  StreamSubscription? _stateSubscription;
  StreamSubscription? _warnappSignalSubscription;
  StreamSubscription? _warnappAbfahrtSubscription;

  void _init() {
    _listenToSferaRemoteRepo();
  }

  Future<bool> get isWaraAppInstalled => _appCheck.isAppInstalled(_waraAppId);

  Future<void> openWaraApp() async {
    try {
      await _appCheck.launchApp(_waraAppId);
    } catch (_) {
      _log.info('Opening Wara app failed or was canceled by user');
    }
  }

  void toggleManeuverMode() => setManeuverMode(!_rxManeuverModeEnabled.value);

  void setManeuverMode(bool active) {
    _log.info('Maneuver mode state changed to active=$active');
    _rxManeuverModeEnabled.add(active);
    if (active) {
      _notificationViewModel.insert(type: .maneuverMode);
    } else {
      _notificationViewModel.remove(type: .maneuverMode);
    }

    if (Platform.isIOS) {
      active ? _warnappRepo.disable() : _warnappRepo.enable();
    }
  }

  void dispose() {
    _rxWarnapp.close();
    _stateSubscription?.cancel();
    _warnappSignalSubscription?.cancel();
    _warnappAbfahrtSubscription?.cancel();
  }

  String get _waraAppId => Platform.isAndroid ? flavor.waraAndroidPackageName : '${flavor.waraIOSUrlScheme}://';

  void _listenToSferaRemoteRepo() {
    _stateSubscription?.cancel();
    _stateSubscription = _sferaRepo.stateStream.listen((state) {
      switch (state) {
        case .offlineData:
        case .connected:
          _enableWarnapp();
          break;
        case .connecting:
          break;
        case .disconnected:
          _disableWarnapp();
          _rxManeuverModeEnabled.add(false);
          break;
      }
    });
  }

  void _enableWarnapp() async {
    final isWarnappFeatEnabled = await _ruFeatureProvider.isRuFeatureEnabled(.warnapp) && Platform.isIOS;
    _log.info('Warnapp is ${isWarnappFeatEnabled ? 'enabled' : 'disabled'} for active train');
    if (isWarnappFeatEnabled) {
      _warnappAbfahrtSubscription = _warnappRepo.abfahrtEventStream.listen((_) => _handleAbfahrtEvent());
      _warnappSignalSubscription = _sferaRepo.warnappEventStream.listen((_) {
        _lastWarnappEventTimestamp = DateTime.now();
      });
      _warnappRepo.enable();
    }
  }

  void _disableWarnapp() {
    _warnappRepo.disable();
    _warnappAbfahrtSubscription?.cancel();
    _warnappAbfahrtSubscription = null;
    _warnappSignalSubscription?.cancel();
    _warnappSignalSubscription = null;
    _lastWarnappEventTimestamp = null;
  }

  void _handleAbfahrtEvent() {
    final now = DateTime.now();
    if (_lastWarnappEventTimestamp != null &&
        now.difference(_lastWarnappEventTimestamp!).inMilliseconds < _warnappWindowMilliseconds) {
      _log.info('Abfahrt detected while warnapp message was within $_warnappWindowMilliseconds ms -> Warning!');
      _rxWarnapp.add(WarnappEvent());
    }
  }
}
