import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:collection/collection.dart';
import 'package:personal_notes/component.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

class JourneyViewModel({
  required final SettingsRepository _settingsRepository,
  required final SferaJourneyViewModel _sferaJourneyViewModel,
  required final RuIndicationsRepository _ruIndicationsRepository,
  required final PersonalNotesRepository _personalNotesRepository,
}) {
  this {
    _init();
  }

  Stream<Journey?> get journey => _rxJourney.stream;

  Stream<String?> get formattedTrainIdentifier => _rxFormattedTrainIdentifier.stream;

  String? get formattedTrainIdentifierValue => _rxFormattedTrainIdentifier.value;

  Journey? get journeyValue => _rxJourney.value;

  final _rxJourney = BehaviorSubject<Journey?>.seeded(null);
  final _rxFormattedTrainIdentifier = BehaviorSubject<String?>.seeded(null);
  final _ruIndications = <RuIndication>[];
  final _allNotes = <PersonalNote>[];

  StreamSubscription? _journeySubscription;
  StreamSubscription? _ruIndicationsSubscription;
  StreamSubscription? _personalNotesSubscription;

  void dispose() {
    _rxJourney.close();
    _rxFormattedTrainIdentifier.close();
    _journeySubscription?.cancel();
    _ruIndicationsSubscription?.cancel();
    _personalNotesSubscription?.cancel();
  }

  void _init() {
    _initJourneySubscription();
    _initPersonalNotesSubscription();
  }

  void _initJourneySubscription() {
    _journeySubscription?.cancel();
    _journeySubscription = _sferaJourneyViewModel.journey.listen((sferaJourney) async {
      final lastJourney = journeyValue;
      _handleRuIndications(sferaJourney, lastJourney);
      _handleFormattedTrainIdentification(sferaJourney);
      _emit(sferaJourney);
    });
  }

  void _handleRuIndications(Journey? journey, Journey? lastJourney) {
    if (journey?.metadata.trainIdentification != lastJourney?.metadata.trainIdentification) {
      _ruIndications.clear();
    }

    if (_shouldLoadRuIndications(journey, lastJourney)) {
      _loadRuIndications(journey);
    }
  }

  void _initPersonalNotesSubscription() {
    _personalNotesSubscription?.cancel();
    _personalNotesSubscription = _personalNotesRepository.observeAllNotes().listen((notes) {
      _allNotes.clear();
      _allNotes.addAll(notes);
      _emit();
    });
  }

  Future<void> _handleFormattedTrainIdentification(Journey? journey) async {
    final trainIdentification = journey?.metadata.trainIdentification;
    if (trainIdentification == null) {
      _rxFormattedTrainIdentifier.add(null);
    } else {
      final trainNumber = trainIdentification.trainNumber;
      final companyName = await _settingsRepository.getCompanyForCode(trainIdentification.companyCode);
      final hasShuntingMovement = journeyValue?.data.any((data) => data is ShuntingMovement) ?? false;
      final displayedTrainNumber = hasShuntingMovement ? '${trainNumber}R / $trainNumber' : trainNumber;
      _rxFormattedTrainIdentifier.add('$displayedTrainNumber ${companyName?.shortName ?? ''}'.trim());
    }
  }

  bool _shouldLoadRuIndications(Journey? journey, Journey? lastJourney) {
    if (lastJourney == null || journey == null) {
      return true;
    }
    final locationReferences = [for (final it in journey.data.whereType<ServicePoint>()) it.locationCode];
    final lastLocationReferences = [for (final it in lastJourney.data.whereType<ServicePoint>()) it.locationCode];

    return const ListEquality().equals(locationReferences, lastLocationReferences) == false;
  }

  void _loadRuIndications(Journey? journey) {
    final trainIdentification = journey?.metadata.trainIdentification;
    if (trainIdentification != null) {
      final servicePoints = journey!.data.whereType<ServicePoint>();
      final locationReferences = {for (final it in servicePoints) it.order: it.locationCode};

      _ruIndicationsSubscription?.cancel();
      _ruIndicationsSubscription = _ruIndicationsRepository
          .fetchRuIndications(trainIdentification: trainIdentification, locationReferences: locationReferences)
          .listen((ruIndications) {
            _ruIndications.clear();
            _ruIndications.addAll(ruIndications);
            _emit();
          });
    }
  }

  List<PersonalNoteAnnotation> _journeyRelevantPersonalNoteAnnotations(Journey sferaJourney) {
    final notesByLocationCode = <String, PersonalNote>{
      for (final note in _allNotes)
        if (note.isRelevantFor(sferaJourney)) note.locationCode: note,
    };

    final annotations = <PersonalNoteAnnotation>[];
    final servicePoints = sferaJourney.journeyPoints.whereType<ServicePoint>().toList(growable: false);
    for (final servicePoint in servicePoints) {
      final note = notesByLocationCode[servicePoint.locationCode];
      if (note == null || !note.showAsFootnote) continue;

      annotations.add(PersonalNoteAnnotation(text: note.text, order: servicePoint.order));
    }

    return annotations;
  }

  void _emit([Journey? sferaJourney]) {
    final journey = sferaJourney ?? _sferaJourneyViewModel.journeyValue;
    if (journey == null) {
      _emitValue(null);
    } else {
      final mergedData = [
        ...journey.data,
        ..._ruIndications,
        ..._journeyRelevantPersonalNoteAnnotations(journey),
      ].sorted((a1, a2) => a1.compareTo(a2));

      final mergedJourney = Journey(metadata: journey.metadata, data: mergedData, valid: journey.valid);
      _emitValue(mergedJourney);
    }
  }

  void _emitValue(Journey? journey) {
    if (!_rxJourney.isClosed) {
      _rxJourney.add(journey);
    }
  }
}

extension _PersonalNoteX on PersonalNote {
  bool isRelevantFor(Journey? journey) =>
      trainIdentification == null || trainIdentification == journey?.metadata.trainIdentification;
}
