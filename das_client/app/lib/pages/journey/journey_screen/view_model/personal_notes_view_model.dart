import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:personal_notes/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('PersonalNotesViewModel');

// TODO: Handle offline mode
// TODO: Modal should stay open when dialog is shown
// TODO: Handle delete in sync
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

  final _rxPersonalNote = BehaviorSubject<PersonalNote?>.seeded(null);
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
      _rxPersonalNote.add(personalNote);
      _log.fine('Personal note saved for location $locationCode');
    } catch (e) {
      _log.severe('Error saving personal note for location $locationCode', e);
      rethrow;
    }
  }

  Future<void> deleteNote() async {
    if (_currentServicePoint == null) return;

    try {
      await _personalNotesRepository.deleteNote(_currentServicePoint!.locationCode);
      _rxPersonalNote.add(null);
      _log.fine('Personal note deleted for location $locationCode');
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
}
