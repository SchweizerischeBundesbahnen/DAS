import 'package:app/util/user_settings.dart';

class MockUserSettings extends UserSettings {
  final Map<String, Object> _settingsMap = {};

  @override
  T getUserSetting<T>(UserSettingKeys key, T defaultValue) {
    if (_settingsMap.containsKey(key.name)) {
      return _settingsMap[key.name] as T;
    } else {
      return defaultValue;
    }
  }

  @override
  Future<void> setUserSetting<T>(UserSettingKeys key, T value) async {
    _settingsMap[key.name] = value as Object;
  }
}
