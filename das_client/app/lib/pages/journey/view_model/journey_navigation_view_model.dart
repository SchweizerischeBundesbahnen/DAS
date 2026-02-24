import 'dart:async';

import 'package:app/pages/journey/view_model/model/journey_navigation_model.dart';
import 'package:app/widgets/table/row/das_table_row_builder.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyNavigationViewModel');

class JourneyNavigationViewModel {
  JourneyNavigationViewModel({required SferaRepository sferaRepo}) : _sferaRepo = sferaRepo {
    _initSferaRemoteStateSubscription();
  }

  final SferaRepository _sferaRepo;
  StreamSubscription<SferaRemoteRepositoryState>? _sferaRemoteStateSubscription;
  final List<TrainIdentification> _trainIds = [];
  final _rxModel = BehaviorSubject<JourneyNavigationModel?>.seeded(null);

  Stream<JourneyNavigationModel?> get model => _rxModel.stream.distinct();

  JourneyNavigationModel? get modelValue => _rxModel.value;

  int get _currentTrainIdIndex => _rxModel.value?.currentIndex ?? -1;

  TrainIdentification? get _currentTrainId => _rxModel.value?.trainIdentification;

  /// replaces the current navigation stack with [trainIds] where a connection will be established for the first train.
  Future<void> replaceWith(Iterable<TrainIdentification> trainIds) async {
    if (_trainIds.isNotEmpty) _sferaRepo.disconnect();
    _trainIds.addAll(trainIds);

    await _establishConnection(trainIds.first);
  }

  Future<void> push(TrainIdentification trainId) async {
    if (_currentTrainId == trainId) return;

    if (_trainIds.isNotEmpty) _sferaRepo.disconnect();

    if (!_trainIds.contains(trainId)) _trainIds.add(trainId);

    await _establishConnection(trainId);
  }

  Future<void> next() async {
    if (_trainIds.isEmpty) return;
    final updatedIdx = _currentTrainIdIndex + 1;
    if (_isOutOfTrainIdsRange(updatedIdx)) return;

    await _sferaRepo.disconnect();
    await _establishConnection(_trainIds[updatedIdx]);
  }

  Future<void> previous() async {
    if (_trainIds.isEmpty) return;
    final updatedIdx = _currentTrainIdIndex - 1;
    if (_isOutOfTrainIdsRange(updatedIdx)) return;

    await _sferaRepo.disconnect();
    await _establishConnection(_trainIds[updatedIdx]);
  }

  void dispose() {
    _log.fine('Disposing JourneyNavigationViewModel');
    _sferaRemoteStateSubscription?.cancel();
    _sferaRepo.disconnect();
    _addToStream(null);
    _trainIds.clear();
    _rxModel.close();
  }

  Future<void> _establishConnection(TrainIdentification trainId) async {
    _log.fine('Establish connection to $trainId');
    DASTableRowBuilder.clearRowKeys();
    await _sferaRepo.connect(trainId);
    _addToStream(trainId);
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
    _sferaRemoteStateSubscription = _sferaRepo.stateStream.listen(
      (s) => switch (s) {
        .disconnected => _sferaRepo.lastError != null ? _reset() : null,
        .connected || .connecting || .offlineData => null,
      },
    );
  }
}
