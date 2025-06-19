import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyNavigationViewModel');

class JourneyNavigationViewModel {
  JourneyNavigationViewModel({required SferaRemoteRepo sferaRepo}) : _sferaRemoteRepo = sferaRepo;

  final SferaRemoteRepo _sferaRemoteRepo;
  final List<TrainIdentification> _trainIds = [];
  final _rxModel = BehaviorSubject<JourneyNavigationModel?>.seeded(null);

  Stream<JourneyNavigationModel?> get model => _rxModel.stream.distinct();

  JourneyNavigationModel? get modelValue => _rxModel.value;

  int get _currentTrainIdIndex => _rxModel.value?.currentIndex ?? -1;

  TrainIdentification? get _currentTrainId => _rxModel.value?.trainIdentification;

  void push(TrainIdentification trainId) {
    if (_trainIds.isNotEmpty && _currentTrainId == trainId) return;

    if (!_trainIds.contains(trainId)) _trainIds.add(trainId);

    _sferaRemoteRepo.connect(trainId);
    _addToStream(trainId);
  }

  void next() {
    if (_trainIds.isEmpty) return;
    if (_currentTrainIdIndex < 0 || _currentTrainIdIndex >= _trainIds.length - 1) return;
    final updatedIdx = _currentTrainIdIndex + 1;
    final trainId = _trainIds[updatedIdx];

    _addToStream(trainId);
  }

  void previous() {
    if (_currentTrainIdIndex <= 0) return;
    final updatedIdx = _currentTrainIdIndex - 1;
    final trainId = _trainIds[updatedIdx];
    _addToStream(trainId);
  }

  void reset() {
    _log.fine('Resetting JourneyNavigationViewModel');
    _trainIds.clear();
    _rxModel.add(null);
  }

  void dispose() {
    _log.fine('Disposing JourneyNavigationViewModel');
    _rxModel.close();
    _trainIds.clear();
  }

  void _addToStream(TrainIdentification trainId) {
    _rxModel.add(
      JourneyNavigationModel(
        trainIdentification: trainId,
        currentIndex: _trainIds.indexOf(trainId),
        navigationStackLength: _trainIds.length,
      ),
    );
  }
}
