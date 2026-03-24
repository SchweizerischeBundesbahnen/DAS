import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('ChecklistDepartureProcessViewModel');

class ChecklistDepartureProcessViewModel extends JourneyAwareViewModel {
  ChecklistDepartureProcessViewModel({
    required JourneyPositionViewModel journeyPositionViewModel,
    required RuFeatureProvider ruFeatureProvider,
    super.journeyViewModel,
  }) : _journeyPositionViewModel = journeyPositionViewModel,
       _ruFeatureProvider = ruFeatureProvider {
    _initSubscription();
  }

  final JourneyPositionViewModel _journeyPositionViewModel;
  final RuFeatureProvider _ruFeatureProvider;

  final _rxShowChronographWarning = BehaviorSubject<bool>.seeded(true);
  final _rxShowDepartureProcessButton = BehaviorSubject<bool>.seeded(false);

  Future<bool> get isDepartureProcessFeatureEnabled => _ruFeatureProvider.isRuFeatureEnabled(.departureProcess);

  StreamSubscription? _positionSubscription;

  Stream<bool> get showChronographWarning => _rxShowChronographWarning.distinct();

  Stream<bool> get showDepartureProcessButton => _rxShowDepartureProcessButton.distinct();

  bool get _streamsClosed => _rxShowChronographWarning.isClosed || _rxShowDepartureProcessButton.isClosed;

  /// Toggles the [showChronographWarning] stream.
  /// Has no effect if the departureProcess RU feature is disabled.
  void toggleChronographWarning() {
    isDepartureProcessFeatureEnabled.then((enabled) {
      if (!enabled) {
        _log.info('Ignoring chronographWarning toggle: departureProcess feature is disabled');
        return;
      }
      final newValue = !_rxShowChronographWarning.value;
      _log.info('User toggled chronographWarning to $newValue');
      _rxShowChronographWarning.add(newValue);
    });
  }

  void _initSubscription() {
    _positionSubscription = _journeyPositionViewModel.model.listen((positionModel) async {
      await _updateDepartureProcessEnabled(positionModel);
    });
  }

  Future<void> _updateDepartureProcessEnabled(JourneyPositionModel positionModel) async {
    if (_streamsClosed) return;

    final currentPosition = positionModel.currentPosition;
    final isEligiblePosition = _isEligiblePosition(currentPosition);
    _log.fine('departureProcessEnabled: isEligiblePosition=$isEligiblePosition');
    _rxShowDepartureProcessButton.add(isEligiblePosition);
  }

  bool _isEligiblePosition(JourneyPoint? position) {
    if (position == null && lastJourney?.metadata.journeyStart is ServicePoint) {
      return true;
    }

    return switch (position) {
      ServicePoint _ => true,
      final Signal s => s.functions.contains(SignalFunction.intermediate),
      _ => false,
    };
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _rxShowChronographWarning.add(true);
    _rxShowDepartureProcessButton.add(false);
  }

  @override
  void dispose() {
    super.dispose();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _rxShowChronographWarning.close();
    _rxShowDepartureProcessButton.close();
  }
}
