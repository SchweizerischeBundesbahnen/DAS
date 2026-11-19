import 'dart:async';

import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:voice_chat/component.dart';

final _log = Logger('VoiceChatViewModel');

class VoiceChatViewModel({
  required final VoiceChatRepository _repository,
  super.journeyViewModel,
}) extends JourneyAwareViewModel {
  Future<void> _pendingChange = Future.value();
  int _revision = 0;
  bool _disposed = false;
  Future<void>? _closeFuture;

  @override
  void onJourneyChanged(Journey? journey) {
    final train = journey?.metadata.trainIdentification;
    final revision = ++_revision;
    _pendingChange = _pendingChange.then((_) async {
      if (_disposed || revision != _revision) return;
      try {
        if (train == null) {
          await _repository.disconnect();
        } else {
          final key = VoiceRoomKey.fromJourney(trainNumber: train.trainNumber, date: train.date);
          _log.fine('Connecting voice chat to room ${key.value}');
          await _repository.connect(key);
        }
      } catch (error, stackTrace) {
        _log.severe('Failed to change voice chat room', error, stackTrace);
      }
    });
  }

  Future<void> close() {
    dispose();
    return _closeFuture!;
  }

  Future<void> _finishClose() async {
    await _pendingChange;
    await _repository.disconnect();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
    _closeFuture = _finishClose();
  }
}
