import 'package:preload/src/data/drift_preload_database_service.dart';
import 'package:preload/src/repository/preload_repository.dart';
import 'package:preload/src/repository/preload_repository_impl.dart';

export 'package:preload/src/repository/preload_repository.dart';

class PreloadComponent {
  const PreloadComponent._();

  static PreloadRepository createPreloadRepository() => PreloadRepositoryImpl(
    databaseService: DriftPreloadDatabaseService.instance,
  );
}
