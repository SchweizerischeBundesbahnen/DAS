import 'dart:async';

import 'package:app/util/app_lifecycle_view_model.dart';
import 'package:logging/logging.dart';
import 'package:personal_notes/component.dart';
import 'package:sfera/component.dart';

final _log = Logger('AppSyncHandler');

class AppSyncHandler({
  required final AcknowledgedModificationRepository _acknowledgedModificationRepository,
  required final PersonalNotesRepository _personalNotesRepository,
  required final AppLifecycleViewModel _appLifecycleVM,
}) {
  this {
    _onResumedSubscription = _appLifecycleVM.onResumed.listen((_) => _synchronize());
  }

  StreamSubscription<void>? _onResumedSubscription;

  Future<void> _synchronize() async {
    _log.fine('Synchronizing app...');
    _acknowledgedModificationRepository.deleteExpiredModifications();
    _personalNotesRepository.synchronizeNotes();
  }

  void dispose() {
    _onResumedSubscription?.cancel();
    _onResumedSubscription = null;
  }
}
