import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

extension JourneyExtension on Journey {
  /// returns formatted train numbers and RU text (ex. 1809 SBB or 1513R / 1513 BLS)
  String formattedTrainIdentifier(BuildContext context) {
    final trainIdentification = metadata.trainIdentification;
    if (trainIdentification == null) return context.l10n.c_unknown;

    final trainNumber = trainIdentification.trainNumber;
    final displayedTrainNumber = _hasShuntingMovement() ? '${trainNumber}R / $trainNumber' : trainNumber;
    return '$displayedTrainNumber ${trainIdentification.ru.displayText(context)}';
  }

  bool _hasShuntingMovement() => data.any((data) => data is ShuntingMovementMarking);
}
