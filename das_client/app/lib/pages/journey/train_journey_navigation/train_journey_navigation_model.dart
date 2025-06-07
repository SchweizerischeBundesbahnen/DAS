import 'package:sfera/component.dart';

class TrainJourneyNavigationModel {
  final TrainIdentification trainIdentification;
  final int currentIndex;
  final int navigationStackLength;

  TrainJourneyNavigationModel({
    required this.trainIdentification,
    required this.currentIndex,
    required this.navigationStackLength,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainJourneyNavigationModel &&
          runtimeType == other.runtimeType &&
          trainIdentification == other.trainIdentification &&
          currentIndex == other.currentIndex &&
          navigationStackLength == other.navigationStackLength;

  @override
  int get hashCode => Object.hash(trainIdentification, currentIndex, navigationStackLength);

  @override
  String toString() =>
      'TrainJourneyNavigationModel(trainIdentification: $trainIdentification, currentIndex: $currentIndex, navigationStackLength: $navigationStackLength)';
}
