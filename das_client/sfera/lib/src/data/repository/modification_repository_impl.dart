import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/repository/modification_repository.dart';
import 'package:sfera/src/model/modification.dart';

class ModificationRepoImpl implements ModificationRepository {
  const ModificationRepoImpl({required this._databaseService});

  final SferaLocalDatabaseService _databaseService;

  @override
  Stream<List<Modification>> get modificationsStream => _databaseService.observeModifications();

  @override
  Future<void> insert(Modification modification) => _databaseService.saveModification(modification);

  @override
  Future<void> delete(Modification modification) => _databaseService.deleteModification(modification);
}
