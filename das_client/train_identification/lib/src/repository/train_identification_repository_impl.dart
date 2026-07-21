import 'package:logging/logging.dart';
import 'package:train_identification/src/api/dto/company_match_dto.dart';
import 'package:train_identification/src/api/train_identification_api_service.dart';
import 'package:train_identification/src/model/company_match.dart';
import 'package:train_identification/src/repository/train_identification_repository.dart';

final _log = Logger('TrainIdentificationRepositoryImpl');

class TrainIdentificationRepositoryImpl implements TrainIdentificationRepository {
  TrainIdentificationRepositoryImpl({
    required this.apiService,
  });

  final TrainIdentificationApiService apiService;

  @override
  Future<List<CompanyMatch>> findTrainIdentifications({
    required String operationalTrainNumber,
  }) async {
    final now = DateTime.now();
    final startDates = [
      now.subtract(const Duration(days: 1)),
      now,
      now.add(const Duration(days: 1)),
    ];

    _log.fine('Fetching train identifications for $operationalTrainNumber on $startDates');

    final response = await apiService.companies(
      operationalTrainNumber: operationalTrainNumber,
      startDates: startDates,
    );

    final companyMatches = response.body.data.map((dto) => dto.toCompanyMatch()).toList();
    _log.info('Successfully fetched ${companyMatches.length} company matches for train $operationalTrainNumber.');

    return companyMatches;
  }
}
