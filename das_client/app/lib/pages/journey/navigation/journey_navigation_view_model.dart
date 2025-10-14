import 'dart:async';

import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:app/widgets/table/das_table_row.dart';
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

  Future<void> push(TrainIdentification trainId) async {
    if (_currentTrainId == trainId) return;

    if (_trainIds.isNotEmpty) _sferaRemoteRepo.disconnect();

    if (!_trainIds.contains(trainId)) _trainIds.add(trainId);

    DASTableRowBuilder.clearRowKeys();
    await _sferaRemoteRepo.connect(trainId);
    _addToStream(trainId);
  }

  Future<void> next() async {
    if (_trainIds.isEmpty) return;
    final updatedIdx = _currentTrainIdIndex + 1;
    if (_isOutOfTrainIdsRange(updatedIdx)) return;

    await _sferaRemoteRepo.disconnect();

    final trainId = _trainIds[updatedIdx];
    DASTableRowBuilder.clearRowKeys();
    await _sferaRemoteRepo.connect(trainId);
    _addToStream(trainId);
  }

  Future<void> previous() async {
    if (_trainIds.isEmpty) return;
    final updatedIdx = _currentTrainIdIndex - 1;
    if (_isOutOfTrainIdsRange(updatedIdx)) return;

    await _sferaRemoteRepo.disconnect();

    final trainId = _trainIds[updatedIdx];
    DASTableRowBuilder.clearRowKeys();
    await _sferaRemoteRepo.connect(trainId);
    _addToStream(trainId);
  }

  void dispose() {
    _log.fine('Disposing JourneyNavigationViewModel');
    _sferaRemoteStateSubscription?.cancel();
    _sferaRemoteRepo.disconnect();
    _addToStream(null);
    _trainIds.clear();
    _rxModel.close();
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
        showNavigationButtons: _trainIds.length > 1,
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
