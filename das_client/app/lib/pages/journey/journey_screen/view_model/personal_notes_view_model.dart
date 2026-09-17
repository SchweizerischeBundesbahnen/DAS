import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:personal_notes/component.dart';
import 'package:rxdart/rxdart.dart';

class PersonalNotesViewModel({
  required final PersonalNotesRepository _personalNotesRepository,
  required final ServicePointModalViewModel _servicePointModalViewModel,
}) {
  this {
    _init();
  }

  Stream<PersonalNote?> get personalNote => _rxPersonalNote.distinct();

  final _rxPersonalNote = BehaviorSubject<PersonalNote?>.seeded(null);
  final _subscriptions = <StreamSubscription>[];

  // TODO: implement save, synchronize and delete

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    _rxPersonalNote.close();
  }

  void _init() {
    final subscription = _servicePointModalViewModel.servicePoint.listen((servicePoint) async {
      final personalNote = await _personalNotesRepository.findNote(servicePoint.locationCode);
      _rxPersonalNote.add(personalNote);
    });
    _subscriptions.add(subscription);
  }
}
