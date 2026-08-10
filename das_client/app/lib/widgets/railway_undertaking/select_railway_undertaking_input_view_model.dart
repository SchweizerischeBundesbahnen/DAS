import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';

final _log = Logger('SelectRailwayUndertakingInputViewModel');

class SelectRailwayUndertakingInputViewModel {
  SelectRailwayUndertakingInputViewModel({required this._settingsRepository}) {
    _init();
  }

  final SettingsRepository _settingsRepository;
  final _rxCompanies = BehaviorSubject<List<Company>>.seeded([]);

  Stream<List<Company>> get companies => _rxCompanies.stream.distinct();

  Future<void> _init() async {
    try {
      final companies = await _settingsRepository.getCompanies();
      _rxCompanies.add(companies);
    } catch (e, stackTrace) {
      _log.severe('Failed to load companies.', e, stackTrace);
    }
  }

  void dispose() {
    _rxCompanies.close();
  }
}
