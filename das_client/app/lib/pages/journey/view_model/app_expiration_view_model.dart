import 'dart:async';

import 'package:app/pages/journey/view_model/model/app_expiration_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';

class AppExpirationViewModel {
  AppExpirationViewModel({required SettingsRepository settingsRepository, required String currentAppVersion})
    : _settingsRepository = settingsRepository,
      _currentAppVersion = currentAppVersion,
      _rxSubject = BehaviorSubject<AppExpirationModel>.seeded(Valid(currentAppVersion: currentAppVersion)) {
    checkIsAppExpired();
  }

  Stream<AppExpirationModel> get model => _rxSubject.stream.distinct();

  AppExpirationModel get modelValue => _rxSubject.value;

  static const throttleDuration = Duration(minutes: 30);

  final SettingsRepository _settingsRepository;
  final BehaviorSubject<AppExpirationModel> _rxSubject;
  final String _currentAppVersion;
  AppVersionExpiration? _lastSetting;
  bool _dialogDismissed = false;

  /// do not make a request to load settings more frequent than every [throttleDuration]
  Timer? _throttleTimer;
  bool _isLoading = false;

  bool get mustShowDialog => switch (modelValue) {
    Expired() => true,
    ExpirySoon(expiryDate: final _, userDismissedDialog: final userDismissedDialog) => !userDismissedDialog,
    Valid() => false,
  };

  Future<void> checkIsAppExpired() {
    _lastSetting = _settingsRepository.appVersionExpiration ?? _lastSetting;

    if (_throttleTimer == null && !_isLoading) {
      return _loadSettings();
    } else {
      return Future.value();
    }
  }

  Future<void> _loadSettings() {
    _isLoading = true;

    return _settingsRepository.loadSettings().then((success) {
      _isLoading = false;
      _throttleTimer = Timer(throttleDuration, () => _throttleTimer = null);
      if (success) {
        _lastSetting = _settingsRepository.appVersionExpiration;
        _emitModel();
      }
    });
  }

  void dialogDismissedByUser() {
    if (_dialogDismissed) return;
    _dialogDismissed = true;
    _emitModel();
  }

  void dispose() {
    _lastSetting = null;
    _dialogDismissed = false;
    _isLoading = false;
    _throttleTimer?.cancel();
    _throttleTimer = null;
    _rxSubject.close();
  }

  void _emitModel() {
    final model = _modelFromInternalState();
    if (!_rxSubject.isClosed) _rxSubject.add(model);
  }

  AppExpirationModel _modelFromInternalState() {
    final setting = _lastSetting;
    if (setting == null) return Valid(currentAppVersion: _currentAppVersion);

    if (setting.expired) return Expired(currentAppVersion: _currentAppVersion);
    if (setting.expiryDate != null) {
      return ExpirySoon(
        expiryDate: setting.expiryDate!,
        userDismissedDialog: _dialogDismissed,
        currentAppVersion: _currentAppVersion,
      );
    }
    return Valid(currentAppVersion: _currentAppVersion);
  }
}
