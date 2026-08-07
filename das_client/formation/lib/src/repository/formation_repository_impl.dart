import 'package:formation/src/api/formation_api_service.dart';
import 'package:formation/src/data/local/formation_database_service.dart';
import 'package:formation/src/model/formation.dart';
import 'package:formation/src/model/transport_paper_link.dart';
import 'package:formation/src/repository/formation_repository.dart';
import 'package:logging/logging.dart';

final _log = Logger('FormationRepositoryImpl');

class FormationRepositoryImpl implements FormationRepository {
  FormationRepositoryImpl({required this._apiService, required this._databaseService});

  final FormationApiService _apiService;
  final FormationDatabaseService _databaseService;

  @override
  Future<Formation?> reloadFormation(String operationalTrainNumber, String company, DateTime operationalDay) async {
    operationalTrainNumber = _sanitizeTrainNumber(operationalTrainNumber);
    await _loadFormationAndUpdateDatabase(operationalTrainNumber, company, operationalDay);
    return _databaseService.findFormation(operationalTrainNumber, company, operationalDay);
  }

  Future<void> _loadFormationAndUpdateDatabase(
    String operationalTrainNumber,
    String company,
    DateTime operationalDay,
  ) async {
    _log.info('Loading formation for train $operationalTrainNumber (company=$company) on $operationalDay');
    try {
      final existingEtag = await _databaseService.findFormationEtag(operationalTrainNumber, company, operationalDay);

      final formationResponse = await _apiService
          .formation(operationalTrainNumber, company, operationalDay, existingEtag)
          .call();

      final etag = formationResponse.etag;
      final formation = formationResponse.body?.data.firstOrNull;
      if (formation != null) {
        await _databaseService.saveFormation(formation, etag: formationResponse.etag);
        _log.info('Formation loaded successfully. etag=${formationResponse.etag}');
      } else if (existingEtag != null && existingEtag == etag) {
        _log.info('Formation not modified. etag=${formationResponse.etag}');
      } else {
        await _databaseService.deleteFormation(operationalTrainNumber, company, operationalDay);
        _log.info('No formation found. Deleting local formation. etag=${formationResponse.etag}');
      }
    } catch (e) {
      _log.severe('Connection error while loading formation', e);
    }
  }

  @override
  Stream<Formation?> watchFormation({
    required String operationalTrainNumber,
    required String company,
    required DateTime operationalDay,
  }) {
    operationalTrainNumber = _sanitizeTrainNumber(operationalTrainNumber);
    reloadFormation(operationalTrainNumber, company, operationalDay);

    return _databaseService
        .watchFormation(operationalTrainNumber, company, operationalDay)
        .distinct((f1, f2) => f1 == f2);
  }

  String _sanitizeTrainNumber(String trainNumber) {
    return trainNumber.replaceAll('M', '');
  }

  @override
  Future<String?> resolveTransportPaperLink(TransportPaperLink transportPaperLink) async {
    _log.info('Resolving $transportPaperLink');
    if (transportPaperLink.type != .pdfRedirect) return transportPaperLink.url;

    try {
      final response = await _apiService.transportPaper(transportPaperLink.url).call();
      _log.info('Resolved $transportPaperLink with ${response.headers}');
      return response.headers['Location'];
    } catch (e) {
      _log.severe('Connection error while resolving $transportPaperLink', e);
      return null;
    }
  }
}
