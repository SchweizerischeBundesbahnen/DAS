import 'package:app/pages/settings/user_settings.dart';

class MockUserSettings extends UserSettings {
  final Map<String, Object> _settingsMap = {};

  @override
  T get<T>(UserSettingKeys key, T defaultValue) {
    if (_settingsMap.containsKey(key.name)) {
      return _settingsMap[key.name] as T;
    } else {
      return defaultValue;
    }
  }

  @override
  Future<void> set<T>(UserSettingKeys key, T value) async {
    _settingsMap[key.name] = value as Object;
  }
}
