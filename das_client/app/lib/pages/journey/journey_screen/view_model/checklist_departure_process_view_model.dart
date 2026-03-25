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

  final _rxShowDepartureProcessButton = BehaviorSubject<bool>.seeded(false);

  StreamSubscription? _positionSubscription;

  Stream<bool> get showDepartureProcessButton => _rxShowDepartureProcessButton.distinct();

  bool get showDepartureProcessButtonValue => _rxShowDepartureProcessButton.value;

  void _initSubscription() {
    _positionSubscription = _journeyPositionViewModel.model.listen((positionModel) async {
      await _updateDepartureProcessEnabled(positionModel);
    });
  }

  Future<void> _updateDepartureProcessEnabled(JourneyPositionModel positionModel) async {
    if (_rxShowDepartureProcessButton.isClosed) return;
    if (!await (_ruFeatureProvider.isRuFeatureEnabled(.departureProcess))) {
      _rxShowDepartureProcessButton.add(false);
      return;
    }

    final isEligiblePosition = _isEligiblePosition(positionModel.currentPosition);
    _log.fine('showDepartureProcessButton: $isEligiblePosition');
    _rxShowDepartureProcessButton.add(isEligiblePosition);
  }

  bool _isEligiblePosition(JourneyPoint? currentPosition) {
    if (currentPosition == null && lastJourney?.metadata.journeyStart is ServicePoint) {
      return true;
    }

    return switch (currentPosition) {
      ServicePoint _ => true,
      final Signal s => s.functions.contains(SignalFunction.intermediate),
      _ => false,
    };
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _rxShowDepartureProcessButton.add(false);
  }

  @override
  void dispose() {
    super.dispose();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _rxShowDepartureProcessButton.close();
  }
}
