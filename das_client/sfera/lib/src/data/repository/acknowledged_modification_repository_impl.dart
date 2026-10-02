import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/mapper/datetime_x.dart';
import 'package:sfera/src/data/repository/acknowledged_modification_repository.dart';
import 'package:sfera/src/model/journey/journey_point.dart';
import 'package:sfera/src/model/modification.dart';

class AcknowledgedModificationRepositoryImpl({
  required final SferaLocalDatabaseService _databaseService,
}) implements AcknowledgedModificationRepository {
  this {
    _streamSubscription = _databaseService.observeModifications().listen(_rxModel.add);
  }

  final BehaviorSubject<Set<Modification>> _rxModel = BehaviorSubject.seeded({});
  StreamSubscription? _streamSubscription;
  DateTime? _lastCleanupDate;

  @override
  Stream<Set<Modification>> get model => _rxModel.stream;

  @override
  Set<Modification> get modelValue => _rxModel.value;

  @override
  Future<void> insert(Modification modification) async {
    await _databaseService.saveModification(modification);
  }

  @override
  Future<void> deleteExpiredModifications() async {
    final now = DateTime.now();
    if (_lastCleanupDate == null || !_lastCleanupDate!.isSameDay(now)) {
      _lastCleanupDate = now;
      final cutoffDate = now.subtract(const Duration(days: JourneyPoint.showModificationDays));
      await _databaseService.deleteExpiredModification(cutoffDate);
    }
  }

  @override
  Future<void> delete(Modification modification) => _databaseService.deleteModification(modification);

  @override
  void dispose() {
    _rxModel.close();
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
