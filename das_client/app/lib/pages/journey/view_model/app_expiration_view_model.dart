import 'package:app/pages/journey/view_model/model/app_expiration_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';

class AppExpirationViewModel {
  AppExpirationViewModel({required SettingsRepository settingsRepository}) : _settingsRepository = settingsRepository {
    checkIsAppExpired();
  }

  final SettingsRepository _settingsRepository;

  final _rxSubject = BehaviorSubject<AppExpirationModel>.seeded(Valid());

  Stream<AppExpirationModel> get model => _rxSubject.stream.distinct();

  AppExpirationModel get modelValue => _rxSubject.value;

  AppVersionExpiration? _lastSetting;
  bool _dialogDismissed = false;

  bool get mustShowDialog => switch (modelValue) {
    Expired() => true,
    ExpirySoon(expiryDate: final _, userDismissedDialog: final userDismissedDialog) => !userDismissedDialog,
    Valid() => false,
  };

  void checkIsAppExpired() {
    _settingsRepository.loadSettings().then((success) {
      if (success) {
        _lastSetting = _settingsRepository.appVersionExpiration;
        _emitModel();
      }
    });
  }

  void dismissDialog() {
    if (_dialogDismissed) return;
    _dialogDismissed = true;
    _emitModel();
  }

  void dispose() {
    _lastSetting = null;
    _dialogDismissed = false;
    _rxSubject.close();
  }

  void _emitModel() {
    final model = _modelFromInternalState();
    if (!_rxSubject.isClosed) _rxSubject.add(model);
  }

  AppExpirationModel _modelFromInternalState() {
    final setting = _lastSetting;
    if (setting == null || !setting.isExpired) return Valid();

    if (setting.expired) return Expired();
    return ExpirySoon(expiryDate: setting.expiryDate!, userDismissedDialog: _dialogDismissed);
  }
}
