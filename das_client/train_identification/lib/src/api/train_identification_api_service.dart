import 'package:train_identification/src/api/companies/companies_request.dart';

abstract class TrainIdentificationApiService {
  /// Returns matching companies for the given operational train number and start date.
  CompaniesRequest get companies;
}
