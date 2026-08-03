import 'package:app/provider/local_key_value_store.dart';
import 'package:rxdart/rxdart.dart';

class MockLocalKeyValueStore extends LocalKeyValueStore {
  final Map<String, Object> _settingsMap = {};

  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  @override
  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  @override
  T get<T>(LocalKeyValueStoreKeys key, T defaultValue) {
    if (_settingsMap.containsKey(key.name)) {
      return _settingsMap[key.name] as T;
    } else {
      return defaultValue;
    }
  }

  @override
  Future<void> set<T>(LocalKeyValueStoreKeys key, T value) async {
    _settingsMap[key.name] = value as Object;
    _rxModel.add(key);
  }
}
