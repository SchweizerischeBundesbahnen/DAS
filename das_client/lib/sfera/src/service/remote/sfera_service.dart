import 'dart:core';

import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/ux_testing.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/model/message_header.dart';
import 'package:das_client/util/annotations/non_production.dart';
import 'package:das_client/util/device_id_info.dart';
import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:uuid/uuid.dart';

/// Handles connection and message exchange with SFERA broker
abstract class SferaService {
  const SferaService._();

  Stream<SferaServiceState> get stateStream;

  Stream<Journey?> get journeyStream;

  @nonProduction
  Stream<UxTesting?> get uxTestingStream;

  ErrorCode? get lastErrorCode;

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
