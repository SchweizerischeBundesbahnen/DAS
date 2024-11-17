import 'dart:core';

import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/util/device_id_info.dart';
import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:uuid/uuid.dart';

abstract class SferaService {
  const SferaService._();

  Stream<SferaServiceState> get stateStream;

  Stream<Journey?> get journeyStream;

  ErrorCode? get lastErrorCode;

  Future<void> connect(OtnId otnId);

  void disconnect();

  static Future<MessageHeader> messageHeader({TrainIdentification? trainIdentification, required String sender}) async {
    return MessageHeader.create(const Uuid().v4(), Format.sferaTimestamp(DateTime.now()),
        await DeviceIdInfo.getDeviceId(), 'TMS', sender, '0085',
        trainIdentification: trainIdentification);
  }

  static String sferaTrain(String trainNumber, DateTime date) {
    return '${trainNumber}_${Format.sferaDate(date)}';
  }
}
