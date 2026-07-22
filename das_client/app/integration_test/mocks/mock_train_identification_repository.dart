import 'package:core_data/component.dart';
import 'package:train_identification/component.dart';

class MockTrainIdentificationRepository implements TrainIdentificationRepository {
  bool shouldReturnMockData = false;

  @override
  Future<Set<CompanyMatch>> findTrainIdentifications({
    required String operationalTrainNumber,
  }) async {
    if (!shouldReturnMockData) {
      return {
        CompanyMatch(
          ru: RailwayUndertaking.sbbP,
          startDate: DateTime.now(),
        ),
      };
    }

    return {
      CompanyMatch(
        ru: RailwayUndertaking.sbbP,
        startDate: DateTime.now(),
      ),
      CompanyMatch(
        ru: RailwayUndertaking.blsP,
        startDate: DateTime.now(),
      ),
    };
  }
}
