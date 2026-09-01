import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';

class JourneyNavigationModel({
  required final ExtendedTrainIdentification trainIdentification,
  required final int currentIndex,
  required final int navigationStackLength,
  required final bool showNavigationButtons,
}) {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyNavigationModel &&
          runtimeType == other.runtimeType &&
          trainIdentification == other.trainIdentification &&
          currentIndex == other.currentIndex &&
          navigationStackLength == other.navigationStackLength &&
          showNavigationButtons == other.showNavigationButtons;

  @override
  int get hashCode => Object.hash(trainIdentification, currentIndex, navigationStackLength, showNavigationButtons);

  @override
  String toString() {
    return 'JourneyNavigationModel{trainIdentification: $trainIdentification, currentIndex: $currentIndex, navigationStackLength: $navigationStackLength, showNavigationButtons: $showNavigationButtons}';
  }
}
