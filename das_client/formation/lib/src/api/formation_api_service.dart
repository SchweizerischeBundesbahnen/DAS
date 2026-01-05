import 'package:formation/src/api/endpoint/formation.dart';

abstract class FormationApiService {
  FormationRequest formation(String operationalTrainNumber, String company, DateTime operationalDay, String? etag);
}
