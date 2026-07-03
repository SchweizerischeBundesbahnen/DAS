import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:rxdart/rxdart.dart';

/// Mock implementation of SimTrainViewModel for integration testing.
/// Allows setting the SIM train state for testing purposes.
class MockSimTrainViewModel extends SimTrainViewModel {
  MockSimTrainViewModel() : super(journeyViewModel: null);

  final _mockIsSimTrain = BehaviorSubject<bool>.seeded(false);

  @override
  Stream<bool> get isSimTrain => _mockIsSimTrain.stream;

  @override
  bool get isSimTrainValue => _mockIsSimTrain.value;

  /// Set the SIM train state for testing
  void setIsSimTrain(bool value) {
    _mockIsSimTrain.add(value);
  }

  @override
  void onJourneyChanged(journey) {
    // Do nothing in mock
  }

  @override
  void onJourneyUpdated(journey) {
    // Do nothing in mock
  }

  void closeMock() {
    _mockIsSimTrain.close();
  }
}
