import 'package:core_data/component.dart';
import 'package:train_identification/component.dart';

class MockTrainIdentificationRepository implements TrainIdentificationRepository {
  bool shouldReturnMockData = false;

  @override
  Future<List<Company>> findTrainIdentifications({
    required String operationalTrainNumber,
  }) async {
    if (!shouldReturnMockData) {
      return [Company(code: RailwayUndertaking.sbbP.companyCode, shortName: RailwayUndertaking.sbbP.toString())];
    }

    return [
      Company(code: '1085', shortName: 'SBB'),
      Company(code: '0421', shortName: 'BLS'),
    ];
  }
}
