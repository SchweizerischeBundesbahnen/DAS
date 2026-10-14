import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:personal_notes/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('PersonalNotesViewModel');

class PersonalNotesViewModel({
  required final PersonalNotesRepository _personalNotesRepository,
  required final ServicePointModalViewModel _servicePointModalViewModel,
}) extends JourneyAwareViewModel {
  this {
    _init();
  }

  String? get locationCode => _currentServicePoint?.locationCode;

  bool get servicePointHasMultipleNotes => _rxServicePointNotes.value.length > 1;

  PersonalNote? get prioritizedNoteValue => _rxPrioritizedNote.value;

  /// Personal notes for the current service point.
  Stream<List<PersonalNote>> get servicePointNotes => _rxServicePointNotes.stream;

  /// Prioritized note to be used in UI which is the single use note if multiple exist.
  Stream<PersonalNote?> get prioritizedNote => _rxPrioritizedNote.stream;

  /// Personal notes that are shown as foot note in journey.
  Stream<List<PersonalNoteAnnotation>> get personalNoteAnnotations => _rxPersonalNotesAnnotation.stream;

  final _rxPersonalNotesAnnotation = BehaviorSubject<List<PersonalNoteAnnotation>>.seeded(const []);
  final _rxServicePointNotes = BehaviorSubject<List<PersonalNote>>.seeded(const []);
  final _rxPrioritizedNote = BehaviorSubject<PersonalNote?>.seeded(null);
  final _subscriptions = <StreamSubscription>[];

  ServicePoint? _currentServicePoint;
  List<ServicePoint> _journeyServicePoints = const [];
  List<PersonalNote> _allNotes = const [];
  Journey? _currentJourney;

  @override
  void onJourneyChanged(Journey? journey) => _handleJourneyUpdate(journey);

  @override
  void onJourneyUpdated(Journey? journey) => _handleJourneyUpdate(journey);

  Future<void> saveNote({required String text, required bool showAsFootnote, required bool singleUse}) async {
    if (locationCode == null) {
      _log.warning('Called saveNote without a given locationCode');
      return;
    }

    TrainIdentification? trainIdentification;
    if (singleUse) {
      trainIdentification = _currentJourney?.metadata.trainIdentification;
      if (trainIdentification == null) {
        _log.warning('Called saveNote without existing train identification');
        return;
      }
    }

    final personalNote = PersonalNote(
      locationCode: locationCode!,
      text: text,
      showAsFootnote: showAsFootnote,
      lastModifiedAt: DateTime.now(),
      trainIdentification: trainIdentification,
    );

    try {
      await _personalNotesRepository.saveNote(personalNote);
      _log.fine('Personal note saved for location $locationCode');
    } catch (e) {
      _log.severe('Error saving personal note for location $locationCode', e);
      rethrow;
    }
  }

  Future<void> deleteNote(PersonalNote note) async {
    try {
      await _personalNotesRepository.deleteNote(note);
      _log.fine('Personal note deleted for location $locationCode');
    } catch (e, st) {
      _log.severe('Error deleting personal note', e, st);
      rethrow;
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    _rxServicePointNotes.close();
    _rxPersonalNotesAnnotation.close();
    _rxPrioritizedNote.close();
    super.dispose();
  }

  void _init() {
    final servicePointNotesSubscription = _servicePointModalViewModel.servicePoint
        .doOnData((servicePoint) => _currentServicePoint = servicePoint)
        .switchMap((servicePoint) => _personalNotesRepository.observeNotes(servicePoint.locationCode))
        .listen(
          (notes) => _emitServicePointNotes(notes),
          onError: (e, st) => _log.severe('Error loading personal notes of service point', e, st),
        );
    _subscriptions.add(servicePointNotesSubscription);

    final allNotesSubscription = _personalNotesRepository.observeAllNotes().listen(
      (notes) {
        _allNotes = notes;
        _emitPersonalNoteAnnotations();
      },
      onError: (e, st) => _log.severe('Error loading personal notes as journey annotations', e, st),
    );
    _subscriptions.add(allNotesSubscription);

    final notesSubscription = _rxServicePointNotes.listen((notes) {
      if (notes.isEmpty) {
        _rxPrioritizedNote.add(null);
        return;
      }
      final prioritizedNote = notes.firstWhereOrNull((note) => note.trainIdentification != null) ?? notes.first;
      _rxPrioritizedNote.add(prioritizedNote);
    });
    _subscriptions.add(notesSubscription);
  }

  void _handleJourneyUpdate(Journey? journey) {
    final trainIdentificationChanged =
        _currentJourney?.metadata.trainIdentification != journey?.metadata.trainIdentification;
    _currentJourney = journey;

    if (journey == null) {
      _journeyServicePoints = const [];
      _rxPersonalNotesAnnotation.add(const []);
      return;
    }

    final servicePoints = journey.journeyPoints.whereType<ServicePoint>().toList(growable: false);
    if (!trainIdentificationChanged && !servicePoints.hasChanges(_journeyServicePoints)) return;

    _journeyServicePoints = servicePoints;
    _emitPersonalNoteAnnotations();
  }

  void _emitServicePointNotes(List<PersonalNote> notes) {
    if (_rxServicePointNotes.isClosed) return;

    final journeyRelevantNotes = notes.where((note) => note.isRelevantFor(_currentJourney)).toList();
    _rxServicePointNotes.add(journeyRelevantNotes);
  }

  void _emitPersonalNoteAnnotations() {
    if (_rxPersonalNotesAnnotation.isClosed) return;

    final notesByLocationCode = <String, PersonalNote>{
      for (final note in _allNotes)
        if (note.isRelevantFor(_currentJourney)) note.locationCode: note,
    };

    final annotations = <PersonalNoteAnnotation>[];
    for (final servicePoint in _journeyServicePoints) {
      final note = notesByLocationCode[servicePoint.locationCode];
      if (note == null || !note.showAsFootnote) continue;

      annotations.add(PersonalNoteAnnotation(text: note.text, order: servicePoint.order));
    }

    _rxPersonalNotesAnnotation.add(annotations);
  }
}

extension _ServicePointListX on List<ServicePoint> {
  bool hasChanges(List<ServicePoint> updatedList) {
    if (length != updatedList.length) return true;

    final sortedOriginal = sortedBy((sP) => sP.order);
    final sortedUpdated = updatedList.sortedBy((sP) => sP.order);
    return Iterable.generate(length).any((i) {
      final original = sortedOriginal[i];
      final updated = sortedUpdated[i];
      return original.locationCode != updated.locationCode || original.order != updated.order;
    });
  }
}

extension _PersonalNoteX on PersonalNote {
  bool isRelevantFor(Journey? journey) =>
      trainIdentification == null || trainIdentification == journey?.metadata.trainIdentification;
}
