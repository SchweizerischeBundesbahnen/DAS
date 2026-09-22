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

// TODO: Handle multiple notes in UI with temporary notes
// TODO: Handle offline mode
class PersonalNotesViewModel({
  required final PersonalNotesRepository _personalNotesRepository,
  required final ServicePointModalViewModel _servicePointModalViewModel,
}) extends JourneyAwareViewModel {
  this {
    _init();
  }

  String? get locationCode => _currentServicePoint?.locationCode;

  PersonalNote? get personalNoteValue => _rxPersonalNote.value;

  Stream<PersonalNote?> get personalNote => _rxPersonalNote.distinct();

  Stream<List<PersonalNoteAnnotation>> get personalNoteAnnotations => _rxPersonalNotesAnnotation.stream;

  final _rxPersonalNotesAnnotation = BehaviorSubject<List<PersonalNoteAnnotation>>.seeded(const []);
  final _rxPersonalNote = BehaviorSubject<PersonalNote?>.seeded(null);
  final _subscriptions = <StreamSubscription>[];

  ServicePoint? _currentServicePoint;
  List<ServicePoint> _journeyServicePoints = const [];

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

    final reloadNeeded = _rxPersonalNote.value?.showAsFootnote ?? false;
    try {
      await _personalNotesRepository.saveNote(personalNote);
      _rxPersonalNote.add(personalNote);
      _log.fine('Personal note saved for location $locationCode');

      if (reloadNeeded) {
        _loadPersonalNoteAnnotations();
      }
    } catch (e) {
      _log.severe('Error saving personal note for location $locationCode', e);
      rethrow;
    }
  }

  Future<void> deleteNote() async {
    final noteToDelete = _rxPersonalNote.value;
    if (noteToDelete == null) return;

    try {
      await _personalNotesRepository.deleteNote(noteToDelete.locationCode);
      _rxPersonalNote.add(null);
      _log.fine('Personal note deleted for location $locationCode');

      if (noteToDelete.showAsFootnote) {
        _loadPersonalNoteAnnotations();
      }
    } catch (e) {
      _log.severe('Error deleting personal note', e);
      rethrow;
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    _rxPersonalNote.close();
    _rxPersonalNotesAnnotation.close();
    super.dispose();
  }

  void _init() {
    final subscription = _servicePointModalViewModel.servicePoint.listen((servicePoint) async {
      _currentServicePoint = servicePoint;
      final personalNote = await _personalNotesRepository.findNote(servicePoint.locationCode);
      _rxPersonalNote.add(personalNote);
    });
    _subscriptions.add(subscription);
  }

  void _handleJourneyUpdate(Journey? journey) {
    if (journey == null) {
      _journeyServicePoints = const [];
      _rxPersonalNotesAnnotation.add(const []);
      return;
    }

    final servicePoints = journey.journeyPoints.whereType<ServicePoint>().toList(growable: false);
    if (!servicePoints.hasChanges(_journeyServicePoints)) return;

    _journeyServicePoints = servicePoints;
    _loadPersonalNoteAnnotations();
  }

  Future<void> _loadPersonalNoteAnnotations() async {
    try {
      final notes = await _personalNotesRepository.findAllNotes();
      final notesByLocationCode = <String, PersonalNote>{
        for (final note in notes)
          if (note.trainIdentification == null || note.trainIdentification == lastJourney?.metadata.trainIdentification)
            note.locationCode: note,
      };

      final annotations = <PersonalNoteAnnotation>[];
      for (final servicePoint in _journeyServicePoints) {
        final note = notesByLocationCode[servicePoint.locationCode];
        if (note == null || !note.showAsFootnote) continue;

        annotations.add(PersonalNoteAnnotation(text: note.text, order: servicePoint.order));
      }

      _rxPersonalNotesAnnotation.add(annotations);
    } catch (e) {
      _log.severe('Error loading personal notes as journey annotations', e);
    }
  }
}

extension _ServicePointListX on List<ServicePoint> {
  bool hasChanges(List<ServicePoint> updatedList) {
    if (length != updatedList.length) return true;

    final sortedOriginal = sortedBy((sP) => sP.order);
    final sortedUpdated = sortedBy((sP) => sP.order);
    return Iterable.generate(length).any((i) {
      final original = sortedOriginal[i];
      final updated = sortedUpdated[i];
      return original.locationCode != updated.locationCode || original.order != updated.order;
    });
  }
}
