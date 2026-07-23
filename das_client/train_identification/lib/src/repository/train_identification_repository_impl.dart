import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/src/api/dto/company_match_dto.dart';
import 'package:train_identification/src/api/train_identification_api_service.dart';
import 'package:train_identification/src/repository/train_identification_repository.dart';

final _log = Logger('TrainIdentificationRepositoryImpl');

class TrainIdentificationRepositoryImpl implements TrainIdentificationRepository {
  TrainIdentificationRepositoryImpl({
    required this.apiService,
    required this.sferaLocalRepo,
  });

  final TrainIdentificationApiService apiService;
  final SferaLocalRepo sferaLocalRepo;

  @override
  Future<Set<CompanyMatch>> findTrainIdentifications({
    required String operationalTrainNumber,
  }) async {
    final startDates = _generateStartDates();

    _log.fine('Fetching train identifications for $operationalTrainNumber on $startDates');

    try {
      final response = await apiService.companies(
        operationalTrainNumber: operationalTrainNumber,
        startDates: startDates,
      );

      final companyMatches = response.body.data.map((dto) => dto.toCompanyMatch()).toSet();
      _log.info('Successfully fetched ${companyMatches.length} company matches for train $operationalTrainNumber.');
      return companyMatches;
    } catch (e) {
      _log.info('API call failed for train $operationalTrainNumber, falling back to local database.', e);
      return _findInLocalDatabase(operationalTrainNumber, startDates);
    }
  }

  List<DateTime> _generateStartDates() {
    final now = DateTime.now();
    return [
      now.subtract(const Duration(days: 1)),
      now,
      now.add(const Duration(days: 1)),
    ];
  }

  Future<Set<CompanyMatch>> _findInLocalDatabase(
    String operationalTrainNumber,
    List<DateTime> startDates,
  ) async {
    final matches = await sferaLocalRepo.findCompanyMatchesByTrainNumber(
      operationalTrainNumber,
      startDates: startDates,
    );
    _log.info('Found ${matches.length} local company matches for train $operationalTrainNumber.');
    return matches;
  }
}
