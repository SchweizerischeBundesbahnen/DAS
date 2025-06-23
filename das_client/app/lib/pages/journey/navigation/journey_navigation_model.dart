import 'package:sfera/component.dart';

class JourneyNavigationModel {
  JourneyNavigationModel({
    required this.trainIdentification,
    required this.currentIndex,
    required this.navigationStackLength,
    required this.showNavigationButtons,
  });

  final TrainIdentification trainIdentification;
  final int currentIndex;
  final int navigationStackLength;
  final bool showNavigationButtons;

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
  String toString() =>
      'JourneyNavigationModel(trainIdentification: $trainIdentification, currentIndex: $currentIndex, navigationStackLength: $navigationStackLength, showNavigationButtons: $showNavigationButtons)';
}
