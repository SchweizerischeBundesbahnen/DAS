import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
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

  /// Personal notes relevant for the current journey.
  Stream<List<PersonalNote>> get personalNotes => _rxPersonalNotes.stream;

  List<PersonalNote> get personalNotesValue => _rxPersonalNotes.value;

  /// Personal notes for the selected service point.
  Stream<List<PersonalNote>> get servicePointNotes => _rxServicePointNotes.stream;

  /// Prioritized note of the selected service point which is the single use note if multiple exist.
  Stream<PersonalNote?> get prioritizedNote => _rxPrioritizedNote.stream;

  final _rxPersonalNotes = BehaviorSubject<List<PersonalNote>>.seeded(const []);
  final _rxServicePointNotes = BehaviorSubject<List<PersonalNote>>.seeded(const []);
  final _rxPrioritizedNote = BehaviorSubject<PersonalNote?>.seeded(null);
  final _subscriptions = <StreamSubscription>[];

  ServicePoint? _currentServicePoint;

  Future<void> saveNote({required String text, required bool showAsFootnote, required bool singleUse}) async {
    if (locationCode == null) {
      _log.warning('Called saveNote without a given locationCode');
      return;
    }

    TrainIdentification? trainIdentification;
    if (singleUse) {
      trainIdentification = lastJourney?.metadata.trainIdentification;
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

    _rxPersonalNotes.close();
    _rxServicePointNotes.close();
    _rxPrioritizedNote.close();
    super.dispose();
  }

  void _init() {
    final personalNotesSubscription =
        Rx.combineLatest2(
          _personalNotesRepository.observeAllNotes(),
          journeyViewModel.journey.distinct(
            (previous, next) => previous?.metadata.trainIdentification == next?.metadata.trainIdentification,
          ),
          (notes, journey) => notes.where((note) => note.isRelevantFor(journey)).toList(),
        ).listen(
          _rxPersonalNotes.add,
          onError: (e, st) => _log.severe('Error loading personal notes of journey', e, st),
        );
    _subscriptions.add(personalNotesSubscription);

    final servicePointNotesSubscription = _servicePointModalViewModel.servicePoint
        .doOnData((servicePoint) => _currentServicePoint = servicePoint)
        .switchMap((servicePoint) => _personalNotesRepository.observeNotes(servicePoint.locationCode))
        .listen(
          (notes) => _emitServicePointNotes(notes),
          onError: (e, st) => _log.severe('Error loading personal notes of service point', e, st),
        );
    _subscriptions.add(servicePointNotesSubscription);

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

  void _emitServicePointNotes(List<PersonalNote> notes) {
    if (_rxServicePointNotes.isClosed) return;

    final journeyRelevantNotes = notes.where((note) => note.isRelevantFor(lastJourney)).toList();
    _rxServicePointNotes.add(journeyRelevantNotes);
  }
}

extension PersonalNoteX on PersonalNote {
  bool isRelevantFor(Journey? journey) =>
      trainIdentification == null || trainIdentification == journey?.metadata.trainIdentification;
}
