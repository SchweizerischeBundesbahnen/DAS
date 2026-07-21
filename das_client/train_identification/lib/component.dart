import 'package:http_x/component.dart';
import 'package:train_identification/src/api/train_identification_api_service_impl.dart';
import 'package:train_identification/src/repository/train_identification_repository.dart';
import 'package:train_identification/src/repository/train_identification_repository_impl.dart';

export 'package:train_identification/src/model/company.dart';
export 'package:train_identification/src/model/company_match.dart';
export 'package:train_identification/src/repository/train_identification_repository.dart';

class TrainIdentificationComponent {
  const TrainIdentificationComponent._();

  static TrainIdentificationRepository createRepository({
    required String baseUrl,
    required Client client,
  }) {
    return TrainIdentificationRepositoryImpl(
      apiService: TrainIdentificationApiServiceImpl(baseUrl: baseUrl, httpClient: client),
    );
  }
}
