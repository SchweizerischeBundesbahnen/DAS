import 'package:preload/src/data/drift_preload_database_service.dart';
import 'package:preload/src/repository/preload_repository.dart';
import 'package:preload/src/repository/preload_repository_impl.dart';
import 'package:sfera/component.dart';

export 'package:preload/src/model/preload_details.dart';
export 'package:preload/src/model/s3_file.dart';
export 'package:preload/src/repository/preload_repository.dart';

class PreloadComponent {
  const PreloadComponent._();

  static PreloadRepository createPreloadRepository({
    required SferaLocalRepo sferaLocalRepo,
    bool enablePeriodicPreload = true,
  }) => PreloadRepositoryImpl(
    databaseService: DriftPreloadDatabaseService.instance,
    sferaLocalRepo: sferaLocalRepo,
    enablePeriodicPreload: enablePeriodicPreload, // TODO: added only for development purpose - rm before 1.0 release
  );
}
