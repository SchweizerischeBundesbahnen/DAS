import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('DepartureProcessWarningViewModel');

class DepartureProcessWarningViewModel extends JourneyAwareViewModel {
  DepartureProcessWarningViewModel({
    required RuFeatureProvider ruFeatureProvider,
    super.journeyViewModel,
  }) : _ruFeatureProvider = ruFeatureProvider;

  final RuFeatureProvider _ruFeatureProvider;

  final _rxShowChronographWarning = BehaviorSubject<bool>.seeded(true);

  bool _isDepartureProcessFeatureEnabled = false;

  Stream<bool> get showChronographWarning => _rxShowChronographWarning.distinct();

  bool get showChronographWarningValue => _rxShowChronographWarning.value;

  /// Toggles the [showChronographWarning] stream.
  /// Has no effect if the departureProcess RU feature is disabled.
  void toggleChronographWarning() {
    if (!_isDepartureProcessFeatureEnabled) {
      _log.info('Ignoring chronographWarning toggle: departureProcess feature is disabled');
      return;
    }
    if (_rxShowChronographWarning.isClosed) return;
    final newValue = !_rxShowChronographWarning.value;
    _log.info('User toggled chronographWarning to $newValue');
    _rxShowChronographWarning.add(newValue);
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _ruFeatureProvider.isRuFeatureEnabled(.departureProcess).then((enabled) {
      _isDepartureProcessFeatureEnabled = enabled;
      if (_rxShowChronographWarning.isClosed) return;
      _rxShowChronographWarning.add(enabled);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _rxShowChronographWarning.close();
  }
}
