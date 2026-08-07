import 'package:formation/src/api/endpoint/formation.dart';
import 'package:formation/src/api/endpoint/transport_paper.dart';

abstract class FormationApiService {
  FormationRequest formation(String operationalTrainNumber, String company, DateTime operationalDay, String? etag);
  TransportPaperRequest transportPaper(String relativeUrl);
}
