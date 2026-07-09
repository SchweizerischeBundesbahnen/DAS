import 'package:logging/logging.dart';
import 'package:train_identification/src/api/dto/company_dto.dart';
import 'package:train_identification/src/api/train_identification_api_service.dart';
import 'package:train_identification/src/model/company.dart';
import 'package:train_identification/src/repository/train_identification_repository.dart';

final _log = Logger('TrainIdentificationRepositoryImpl');

class TrainIdentificationRepositoryImpl implements TrainIdentificationRepository {
  TrainIdentificationRepositoryImpl({
    required this.apiService,
  });

  final TrainIdentificationApiService apiService;

  @override
  Future<List<Company>> findTrainIdentifications({
    required String operationalTrainNumber,
  }) async {
    final now = DateTime.now();

    _log.fine('Fetching train identifications for $operationalTrainNumber on $now');

    final response = await apiService.companies(
      operationalTrainNumber: operationalTrainNumber,
      startDate: now,
    );

    final companies = response.body.data.map((dto) => dto.toCompany()).toList();
    _log.info('Successfully fetched ${companies.length} companies for train $operationalTrainNumber.');

    return companies;
  }
}
