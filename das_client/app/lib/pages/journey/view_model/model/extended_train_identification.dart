import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class ExtendedTrainIdentification {
  const ExtendedTrainIdentification({
    required this.trainIdentification,
    this.tafTapLocationReferenceStart,
    this.tafTapLocationReferenceEnd,
    this.returnUrl,
  });

  final TrainIdentification trainIdentification;
  final String? tafTapLocationReferenceStart;
  final String? tafTapLocationReferenceEnd;
  final String? returnUrl;

  @override
  String toString() {
    return 'ExtendedTrainIdentification{trainIdentification: $trainIdentification, tafTapLocationReferenceStart: $tafTapLocationReferenceStart, tafTapLocationReferenceEnd: $tafTapLocationReferenceEnd, returnUrl: $returnUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedTrainIdentification &&
          runtimeType == other.runtimeType &&
          trainIdentification == other.trainIdentification &&
          tafTapLocationReferenceStart == other.tafTapLocationReferenceStart &&
          tafTapLocationReferenceEnd == other.tafTapLocationReferenceEnd &&
          returnUrl == other.returnUrl;

  @override
  int get hashCode =>
      Object.hash(trainIdentification, tafTapLocationReferenceStart, tafTapLocationReferenceEnd, returnUrl);
}
