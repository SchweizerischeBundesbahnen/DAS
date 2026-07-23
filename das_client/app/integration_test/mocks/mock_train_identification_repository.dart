import 'package:core_data/component.dart';
import 'package:train_identification/component.dart';

class MockTrainIdentificationRepository implements TrainIdentificationRepository {
  Set<CompanyMatch> companyMatchData = {
    CompanyMatch(
      ru: RailwayUndertaking.sbbP,
      startDate: DateTime.now(),
    ),
  };

  @override
  Future<Set<CompanyMatch>> findTrainIdentifications({
    required String operationalTrainNumber,
  }) async {
    return companyMatchData;
  }
}
