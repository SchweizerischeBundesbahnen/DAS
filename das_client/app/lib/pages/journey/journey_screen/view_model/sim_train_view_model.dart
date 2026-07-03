import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

/// ViewModel that determines if the current journey is a SIM (Simplon Inter Modal) train.
/// SIM trains have train numbers in the inclusive ranges 43400-43799 or 63400-63799.
class SimTrainViewModel extends JourneyAwareViewModel {
  SimTrainViewModel({super.journeyViewModel});

  Stream<bool> get isSimTrain => _rxIsSimTrain.stream;

  bool get isSimTrainValue => _rxIsSimTrain.value;

  final _rxIsSimTrain = BehaviorSubject<bool>.seeded(false);

  @override
  void onJourneyChanged(Journey? journey) {
    _updateSimTrainState(journey);
  }

  @override
  void onJourneyUpdated(Journey? journey) {
    // Also update on journey updates in case train identification changes
    _updateSimTrainState(journey);
  }

  void _updateSimTrainState(Journey? journey) {
    final trainNumber = journey?.metadata.trainIdentification?.trainNumber;
    _rxIsSimTrain.add(_isSimTrain(trainNumber));
  }

  bool _isSimTrain(String? trainNumber) {
    if (trainNumber == null) return false;
    final trainNum = int.tryParse(trainNumber);
    if (trainNum == null) return false;
    return (trainNum >= 43400 && trainNum <= 43799) || (trainNum >= 63400 && trainNum <= 63799);
  }

  @override
  void dispose() {
    super.dispose();
    _rxIsSimTrain.close();
  }
}
