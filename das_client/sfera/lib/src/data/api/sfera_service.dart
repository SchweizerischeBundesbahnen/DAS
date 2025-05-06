import 'dart:core';

import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/format.dart';

/// Handles connection and message exchange with SFERA broker
abstract class SferaService {
  const SferaService._();

  Stream<SferaServiceState> get stateStream;

  Stream<Journey?> get journeyStream;

  Stream<UxTesting?> get uxTestingStream;

  SferaError? get lastError;

  /// Connect to the SFERA broker with the given [OtnIdDto] train identification
  Future<void> connect(OtnIdDto otnId);

  /// Disconnects from SFERA broker
  Future<void> disconnect();

  void dispose();

  MessageHeaderDto messageHeader({required String sender});

  /// Returns formatted sfera train. Example: 1513_2025-10-10
  static String sferaTrain(String trainNumber, DateTime date) => '${trainNumber}_${Format.sferaDate(date)}';
}
