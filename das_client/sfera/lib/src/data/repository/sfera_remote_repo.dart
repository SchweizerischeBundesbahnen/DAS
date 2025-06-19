import 'dart:core';

import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/otn_id_dto.dart';

/// Handles connection and message exchange with SFERA broker
abstract class SferaRemoteRepo {
  const SferaRemoteRepo._();

  Stream<SferaRemoteRepositoryState> get stateStream;

  Stream<Journey?> get journeyStream;

  Stream<UxTestingEvent?> get uxTestingEventStream;

  Stream<WarnappEvent?> get warnappEventStream;

  SferaError? get lastError;

  /// Connect to the SFERA broker with the given [OtnIdDto] train identification
  Future<void> connect(OtnId otnId);

  /// Disconnects from SFERA broker
  Future<void> disconnect();

  void dispose();

  MessageHeaderDto messageHeader({required String sender});
}
