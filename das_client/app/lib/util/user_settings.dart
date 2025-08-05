import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  UserSettings() {
    _init();
  }

  late SharedPreferences _prefs;

  void _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  T getUserSetting<T>(UserSettingKeys key, T defaultValue) {
    return _prefs.get(key.name) as T? ?? defaultValue;
  }

  Future<void> setUserSetting<T>(UserSettingKeys key, T value) async {
    if (value is bool) {
      await _prefs.setBool(key.name, value);
    } else if (value is int) {
      await _prefs.setInt(key.name, value);
    } else if (value is double) {
      await _prefs.setDouble(key.name, value);
    } else if (value is String) {
      await _prefs.setString(key.name, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key.name, value);
    } else {
      throw ArgumentError('Unsupported type for user setting: ${value.runtimeType}');
    }
  }

  bool get showDecisiveGradient => getUserSetting(UserSettingKeys.showDecisiveGradient, true);
}

enum UserSettingKeys {
  showDecisiveGradient,
}
