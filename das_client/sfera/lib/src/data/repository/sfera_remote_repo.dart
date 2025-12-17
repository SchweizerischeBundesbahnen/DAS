import 'dart:core';

import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';

/// Handles connection and message exchange with SFERA broker
abstract class SferaRemoteRepo {
  const SferaRemoteRepo._();

  Stream<SferaRemoteRepositoryState> get stateStream;

  Stream<Journey?> get journeyStream;

  Stream<UxTestingEvent?> get uxTestingEventStream;

  Stream<WarnappEvent?> get warnappEventStream;

  Stream<DisturbanceEvent?> get disturbanceEventStream;

  Stream<DepartureDispatchNotificationEvent?> get departureDispatchNotificationEventStream;

  SferaError? get lastError;

  TrainIdentification? get connectedTrain;

  /// Connect to the SFERA broker with the given train identification
  Future<void> connect(TrainIdentification otnId);

  /// Disconnects from SFERA broker
  Future<void> disconnect();

  void dispose();

  MessageHeaderDto messageHeader({required String sender});
}
