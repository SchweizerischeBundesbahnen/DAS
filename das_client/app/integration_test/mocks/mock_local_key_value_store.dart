import 'package:rxdart/rxdart.dart';
import 'package:user_properties/component.dart';

class MockLocalKeyValueStore extends LocalKeyValueStore {
  final Map<String, Object?> _settingsMap = {};

  final _rxModel = BehaviorSubject<LocalKeyValueStoreKeys?>.seeded(null);

  MockLocalKeyValueStore({required super.userIdProvider});

  @override
  Stream<LocalKeyValueStoreKeys?> get model => _rxModel.stream;

  @override
  UserPropertyModel get<T>(LocalKeyValueStoreKeys key, T defaultValue) {
    if (_settingsMap.containsKey(key.name)) {
      return UserPropertyModel(
        key: key.name,
        lastUpdated: null,
        value: _settingsMap[key.name],
      );
    } else {
      return UserPropertyModel(
        key: key.name,
        lastUpdated: null,
        value: defaultValue,
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
