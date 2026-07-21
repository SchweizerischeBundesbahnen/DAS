import 'package:core_data/component.dart';

abstract class TrainIdentificationRepository {
  const TrainIdentificationRepository._();

  /// Fetches matching companies (including startDate) for yesterday, today, and tomorrow.
  Future<List<CompanyMatch>> findTrainIdentifications({
    required String operationalTrainNumber,
  });
}
