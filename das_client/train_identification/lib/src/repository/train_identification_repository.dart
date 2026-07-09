import 'package:train_identification/src/model/company.dart';

abstract class TrainIdentificationRepository {
  const TrainIdentificationRepository._();

  /// Fetches the companies for the given operational train number using today's date.
  Future<List<Company>> findTrainIdentifications({
    required String operationalTrainNumber,
  });
}
