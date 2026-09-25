import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/repository/acknowledged_modification_repository.dart';
import 'package:sfera/src/model/modification.dart';

class AcknowledgedModificationRepositoryImpl implements AcknowledgedModificationRepository {
  const AcknowledgedModificationRepositoryImpl({required this._databaseService});

  final SferaLocalDatabaseService _databaseService;

  @override
  Stream<Set<Modification>> get acknowledgedModifications => _databaseService.observeModifications();

  @override
  Future<void> insert(Modification modification) => _databaseService.saveModification(modification);

  @override
  Future<void> delete(Modification modification) => _databaseService.deleteModification(modification);
}
