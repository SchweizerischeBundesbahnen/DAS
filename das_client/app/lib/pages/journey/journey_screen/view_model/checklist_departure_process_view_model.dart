import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/checklist_departure_process_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
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
    required UxTestingViewModel uxTestingViewModel,
    super.journeyViewModel,
  }) : _journeyPositionViewModel = journeyPositionViewModel,
       _ruFeatureProvider = ruFeatureProvider,
       _uxTestingViewModel = uxTestingViewModel {
    _initSubscription();
  }

  final JourneyPositionViewModel _journeyPositionViewModel;
  final RuFeatureProvider _ruFeatureProvider;
  final UxTestingViewModel _uxTestingViewModel;

  final _rxModel = BehaviorSubject<ChecklistDepartureProcessModel>.seeded(const ChecklistDepartureProcessDisabled());

  StreamSubscription<(JourneyPositionModel, KoaState)>? _subscription;

  JourneyPositionModel? _lastPositionModel;
  KoaState _lastKoaState = KoaState.waitHide;

  Stream<ChecklistDepartureProcessModel> get model => _rxModel.distinct();

  ChecklistDepartureProcessModel get modelValue => _rxModel.value;

  void _initSubscription() {
    _subscription =
        CombineLatestStream.combine2(
          _journeyPositionViewModel.model,
          _uxTestingViewModel.koaState,
          (a, b) => (a, b),
        ).listen((data) async {
          _lastPositionModel = data.$1;
          _lastKoaState = data.$2;
          await _updateModel();
        });
  }

  Future<void> _updateModel() async {
    if (!await (_ruFeatureProvider.isRuFeatureEnabled(.departureProcess))) {
      _emitModel(const ChecklistDepartureProcessDisabled());
      return;
    }

    final positionModel = _lastPositionModel;
    final isEligiblePosition = _isEligiblePosition(positionModel?.currentPosition);
    _log.fine('showDepartureProcessButton: $isEligiblePosition');

    if (!isEligiblePosition) {
      _emitModel(const ChecklistDepartureProcessDisabled());
      return;
    }

    final nextStop = positionModel?.nextStop;
    if (_lastKoaState == KoaState.waitHide) {
      _emitModel(NoCustomerOrientedDepartureChecklist(nextStop: nextStop));
    } else {
      _emitModel(CustomerOrientedDepartureChecklist(nextStop: nextStop, koaState: _lastKoaState));
    }
  }

  void _emitModel(ChecklistDepartureProcessModel model) {
    if (_rxModel.isClosed) return;
    _rxModel.add(model);
  }

  bool _isEligiblePosition(JourneyPoint? currentPosition) {
    if (currentPosition == null && lastJourney?.metadata.journeyStart is ServicePoint) {
      return true;
    }

    return switch (currentPosition) {
      final ServicePoint sP => sP.isStop,
      final Signal s => s.functions.contains(SignalFunction.intermediate),
      _ => false,
    };
  }

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _emitModel(const ChecklistDepartureProcessDisabled());
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
    _subscription = null;
    _rxModel.close();
  }
}
