import 'dart:async';

import 'package:app/pages/settings/view_model/model/user_settings_model.dart';
import 'package:core_data/component.dart';
import 'package:external_links/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_properties/component.dart';

class UserSettingsViewModel({
  required final UserPropertiesRepository _userPropertiesRepository,
  required final ExternalLinksRepository _externalLinksRepository,
}) {
  this {
    _init();
  }

  final _rxModel = BehaviorSubject<UserSettingsModel>.seeded(const UserSettingsModel());

  StreamSubscription<LocalKeyValueStoreKeys?>? _userSettingsSubscription;

  Stream<UserSettingsModel> get model => _rxModel.stream.distinct();

  UserSettingsModel get modelValue => _rxModel.value;

  Future<void> updateCompanies(List<Company> companies) async {
    final companyCodes = companies.map((it) => it.code).toList();
    await _userPropertiesRepository.saveUserProperty(LocalKeyValueStoreKeys.companyCodes, companyCodes);
    _externalLinksRepository.reloadExternalLinksByCompanies(companyCodes);
  }

  Future<void> updateTourSystem(TourSystem? tourSystem) =>
      _userPropertiesRepository.saveUserProperty(LocalKeyValueStoreKeys.tourSystem, tourSystem?.name);

  Future<void> updateShowDecisiveGradient(bool value) =>
      _userPropertiesRepository.saveUserProperty(LocalKeyValueStoreKeys.showDecisiveGradient, value);

  Future<void> updateShowStationSignals(bool value) =>
      _userPropertiesRepository.saveUserProperty(LocalKeyValueStoreKeys.showStationSignals, value);

  Future<void> updateShowEctsConventionalSpeedSignals(bool value) =>
      _userPropertiesRepository.saveUserProperty(LocalKeyValueStoreKeys.showEctsConventionalSpeedSignals, value);

  Future<void> updateShowEctsExtendedSpeedSignals(bool value) =>
      _userPropertiesRepository.saveUserProperty(LocalKeyValueStoreKeys.showEctsExtendedSpeedSignals, value);

  void dispose() {
    _userSettingsSubscription?.cancel();
    _rxModel.close();
  }

  void _init() {
    _userSettingsSubscription = _userPropertiesRepository.model.listen((_) => _emitModel());
  }

  void _emitModel() {
    _rxModel.add(
      UserSettingsModel(
        companyCodes: List.unmodifiable(_userPropertiesRepository.companyCodes),
        tourSystem: _userPropertiesRepository.tourSystem,
        showDecisiveGradient: _userPropertiesRepository.showDecisiveGradient,
        showStationSignals: _userPropertiesRepository.showStationSignals,
        showEctsConventionalSpeedSignals: _userPropertiesRepository.showEctsConventionalSpeedSignals,
        showEctsExtendedSpeedSignals: _userPropertiesRepository.showEctsExtendedSpeedSignals,
      ),
    );
  }
}
