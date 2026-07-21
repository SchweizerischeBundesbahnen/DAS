import 'package:core_data/component.dart';
import 'package:train_identification/component.dart';

class MockTrainIdentificationRepository implements TrainIdentificationRepository {
  bool shouldReturnMockData = false;

  @override
  Future<List<CompanyMatch>> findTrainIdentifications({
    required String operationalTrainNumber,
  }) async {
    if (!shouldReturnMockData) {
      return [
        CompanyMatch(
          company: Company(code: RailwayUndertaking.sbbP.companyCode, shortName: RailwayUndertaking.sbbP.toString()),
          startDate: DateTime.now(),
        ),
      ];
    }

    return [
      CompanyMatch(
        company: Company(code: '1085', shortName: 'SBB'),
        startDate: DateTime.now(),
      ),
      CompanyMatch(
        company: Company(code: '0421', shortName: 'BLS'),
        startDate: DateTime.now(),
      ),
    ];
  }
}
