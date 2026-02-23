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
    bool disablePreloadForDevelopment = false,
  }) => PreloadRepositoryImpl(
    databaseService: DriftPreloadDatabaseService.instance,
    sferaLocalRepo: sferaLocalRepo,
    disablePreloadForDevelopment: disablePreloadForDevelopment, // TODO: added only for development purpose
  );
}
