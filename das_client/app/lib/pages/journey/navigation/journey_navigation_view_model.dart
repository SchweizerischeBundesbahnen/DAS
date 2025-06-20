import 'dart:async';

import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyNavigationViewModel');

class JourneyNavigationViewModel {
  JourneyNavigationViewModel({required SferaRemoteRepo sferaRepo}) : _sferaRemoteRepo = sferaRepo {
    _initSferaRemoteStateSubscription();
  }

  final SferaRemoteRepo _sferaRemoteRepo;
  StreamSubscription<SferaRemoteRepositoryState>? _sferaRemoteStateSubscription;
  final List<TrainIdentification> _trainIds = [];
  final _rxModel = BehaviorSubject<JourneyNavigationModel?>.seeded(null);

  Stream<JourneyNavigationModel?> get model => _rxModel.stream.distinct();

  JourneyNavigationModel? get modelValue => _rxModel.value;

  int get _currentTrainIdIndex => _rxModel.value?.currentIndex ?? -1;

  TrainIdentification? get _currentTrainId => _rxModel.value?.trainIdentification;

  void push(TrainIdentification trainId) {
    if (_currentTrainId == trainId) return;
    _log.fine('Pushing');

    if (_trainIds.isNotEmpty) _sferaRemoteRepo.disconnect();

    if (!_trainIds.contains(trainId)) _trainIds.add(trainId);

    _sferaRemoteRepo.connect(trainId);
    _addToStream(trainId);
  }

  void next() {
    if (_trainIds.isEmpty) return;
    final updatedIdx = _currentTrainIdIndex + 1;
    if (_isOutOfTrainIdsRange(updatedIdx)) return;

    _addToStream(_trainIds[updatedIdx]);
  }

  void previous() {
    if (_trainIds.isEmpty) return;
    final updatedIdx = _currentTrainIdIndex - 1;
    if (_isOutOfTrainIdsRange(updatedIdx)) return;

    _addToStream(_trainIds[updatedIdx]);
  }

  void dispose() {
    _log.fine('Disposing JourneyNavigationViewModel');
    _sferaRemoteStateSubscription?.cancel();
    _sferaRemoteRepo.disconnect();
    _rxModel.close();
    _trainIds.clear();
  }

  void _reset() {
    _log.fine('Resetting JourneyNavigationViewModel');
    _trainIds.clear();
    _rxModel.add(null);
  }

  bool _isOutOfTrainIdsRange(int idx) => idx < 0 || idx >= _trainIds.length;

  void _addToStream(TrainIdentification? trainId) {
    if (trainId == null) return _rxModel.add(null);

    _rxModel.add(
      JourneyNavigationModel(
        trainIdentification: trainId,
        currentIndex: _trainIds.indexOf(trainId),
        navigationStackLength: _trainIds.length,
      ),
    );
  }

  void _initSferaRemoteStateSubscription() {
    _sferaRemoteStateSubscription?.cancel();
    _sferaRemoteStateSubscription = _sferaRemoteRepo.stateStream.listen(
      (s) => switch (s) {
        SferaRemoteRepositoryState.disconnected => _sferaRemoteRepo.lastError != null ? _reset() : null,
        SferaRemoteRepositoryState.connected || SferaRemoteRepositoryState.connecting => null,
      },
    );
  }
}
