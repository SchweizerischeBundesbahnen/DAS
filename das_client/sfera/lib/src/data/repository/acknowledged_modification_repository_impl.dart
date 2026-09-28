import 'dart:async';

import 'package:rxdart/subjects.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/repository/acknowledged_modification_repository.dart';
import 'package:sfera/src/model/modification.dart';

class AcknowledgedModificationRepositoryImpl({required this._databaseService})
    implements AcknowledgedModificationRepository {
  this {
    _streamSubscription = _databaseService.observeModifications().listen((data) {
      _rxModel.add(data);
    });
  }

  final SferaLocalDatabaseService _databaseService;
  final BehaviorSubject<Set<Modification>> _rxModel = BehaviorSubject.seeded({});
  StreamSubscription? _streamSubscription;

  @override
  Stream<Set<Modification>> get model => _rxModel.stream;

  @override
  Set<Modification> get modelValue => _rxModel.value;

  @override
  Future<void> insert(Modification modification) => _databaseService.saveModification(modification);

  @override
  Future<void> delete(Modification modification) => _databaseService.deleteModification(modification);

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
