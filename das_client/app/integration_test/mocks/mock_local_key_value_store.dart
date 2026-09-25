import 'package:rxdart/rxdart.dart';
import 'package:user_properties/component.dart';

class MockLocalKeyValueStore extends LocalKeyValueStore {
  final Map<String, Object?> _settingsMap = {};

  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  @override
  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  @override
  UserPropertyModel get<T>(LocalKeyValueStoreKeys key, T defaultValue) {
    if (_settingsMap.containsKey(key.name)) {
      return UserPropertyModel(
        lastUpdated: null,
        value: _settingsMap[key.name].toString(),
      );
    } else {
      return UserPropertyModel(
        lastUpdated: null,
        value: defaultValue.toString(),
      );
    }
  }

  @override
  Future<void> set<T>(LocalKeyValueStoreKeys key, T value) async {
    if (value == null) {
      _settingsMap.remove(key.name);
    } else {
      _settingsMap[key.name] = value as Object;
    }
    _rxModel.add(key);
  }

  @override
  void dispose() {
    _rxModel.close();
  }
}
