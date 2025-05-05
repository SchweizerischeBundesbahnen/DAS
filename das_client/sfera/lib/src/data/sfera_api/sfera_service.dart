import 'dart:core';

import 'package:sfera/src/model/journey/journey.dart';
import 'package:sfera/src/model/journey/ux_testing.dart';
import 'package:app/util/device_id_info.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/message_header.dart';
import 'package:sfera/src/data/format.dart';
import 'package:uuid/uuid.dart';

/// Handles connection and message exchange with SFERA broker
abstract class SferaService {
  const SferaService._();

  Stream<SferaServiceState> get stateStream;

  Stream<Journey?> get journeyStream;

  Stream<UxTesting?> get uxTestingStream;

  SferaError? get lastError;

  /// Connect to the SFERA broker with the given [OtnId] train identification
  Future<void> connect(OtnId otnId);

  /// Disconnects from SFERA broker
  Future<void> disconnect();

  void dispose();

  static Future<MessageHeader> messageHeader({required String sender}) async {
    final deviceId = await DeviceIdInfo.getDeviceId();
    final timestamp = Format.sferaTimestamp(DateTime.now());
    return MessageHeader.create(const Uuid().v4(), timestamp, deviceId, 'TMS', sender, '0085');
  }

  /// Returns formatted sfera train. Example: 1513_2025-10-10
  static String sferaTrain(String trainNumber, DateTime date) => '${trainNumber}_${Format.sferaDate(date)}';
}
