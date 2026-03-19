import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

extension BaseDataX on Iterable<BaseData> {
  Iterable<BaseData> addTrainDriverTurnoverRows(ExtendedTrainIdentification? trainIdentification) {
    if (trainIdentification == null) return this;

    final startLocation = trainIdentification.tafTapLocationReferenceStart;
    final endLocation = trainIdentification.tafTapLocationReferenceEnd;

    if (startLocation == null && endLocation == null) return this;

    final servicePoints = whereType<ServicePoint>();
    final firstServicePoint = servicePoints.firstOrNull;
    final lastServicePoint = servicePoints.lastOrNull;

    final List<BaseData> resultList = toList();

    for (final data in this) {
      if (data == firstServicePoint || data == lastServicePoint) continue;

      if (data is ServicePoint) {
        if (startLocation != null && startLocation == data.locationCode) {
          resultList.add(TrainDriverTurnover(order: data.order, isStart: true));
        } else if (endLocation != null && endLocation == data.locationCode) {
          resultList.add(TrainDriverTurnover(order: data.order, isStart: false));
        }
      }
    }

    return resultList;
  }
}
