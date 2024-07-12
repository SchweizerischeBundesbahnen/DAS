import 'dart:async';

import 'package:das_client/model/sfera/b2g_request.dart';
import 'package:das_client/model/sfera/das_operating_modes_selected.dart';
import 'package:das_client/model/sfera/das_operating_modes_supported.dart';
import 'package:das_client/model/sfera/enums/das_architecture.dart';
import 'package:das_client/model/sfera/enums/das_connectivity.dart';
import 'package:das_client/model/sfera/enums/das_driving_mode.dart';
import 'package:das_client/model/sfera/enums/related_train_request_type.dart';
import 'package:das_client/model/sfera/handshake_request.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/jp_request.dart';
import 'package:das_client/model/sfera/message_header.dart';
import 'package:das_client/model/sfera/otn_id.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/sfera_b2g_request_message.dart';
import 'package:das_client/model/sfera/sfera_reply_parser.dart';
import 'package:das_client/model/sfera/train_identification.dart';
import 'package:das_client/service/mqtt_service.dart';
import 'package:das_client/util/device_id_info.dart';
import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

part 'fahrbild_state.dart';

class FahrbildCubit extends Cubit<FahrbildState> {
  FahrbildCubit({
    required MqttService mqttService,
  })  : _mqttService = mqttService,
        super(SelectingFahrbildState()) {
    _init();
  }

  final MqttService _mqttService;
  StreamSubscription? mqttStreamSubscription;

  DasOperatingModesSelected? operationModeSelected;

  final _journeyProfileSubject = BehaviorSubject<JourneyProfile?>();

  Stream<JourneyProfile?> get journeyStream => _journeyProfileSubject.stream;

  final _segmentProfilesSubject = BehaviorSubject<List<SegmentProfile>>();

  Stream<List<SegmentProfile>> get segmentStream => _segmentProfilesSubject.stream;

  void _init() {
    mqttStreamSubscription = _mqttService.messageStream.listen((message) {
      if (state is RequestingHandshakeState) {
        final currentState = state as BaseFahrbildState;
        var sferaG2bReplyMessage = SferaReplyParser.parse(message);

        if (sferaG2bReplyMessage.validate()) {
          if (sferaG2bReplyMessage.handshakeAcknowledgement != null) {
            Fimber.i("Received handshake acknowledgment");
            operationModeSelected = sferaG2bReplyMessage.handshakeAcknowledgement!.operationModeSelected;
            _requestJourneyProfile();
          } else if (sferaG2bReplyMessage.handshakeReject != null) {
            Fimber.w(
                "Received handshake reject with reason=${sferaG2bReplyMessage.handshakeReject?.handshakeRejectReason?.toString()}");
            _mqttService.disconnect();
            emit(SelectingFahrbildState(
                company: currentState.company,
                trainNumber: currentState.trainNumber,
                errorCode: ErrorCode.sferaHandshakeRejected));
          } else {
            Fimber.w("Ignoring response because is does not contain handshake");
          }
        } else {
          _validationFailed();
        }
      } else if (state is RequestingJourneyState) {
        final currentState = state as BaseFahrbildState;
        var sferaG2bReplyMessage = SferaReplyParser.parse(message);

        if (sferaG2bReplyMessage.validate()) {
          if (sferaG2bReplyMessage.payload != null && sferaG2bReplyMessage.payload!.segmentProfiles.isNotEmpty) {
            Fimber.i("Received G2bReplyPayload response...");
            _journeyProfileSubject.add(sferaG2bReplyMessage.payload!.journeyProfiles.firstOrNull);
            _segmentProfilesSubject.add(sferaG2bReplyMessage.payload!.segmentProfiles.toList());

            Fimber.i("Fahrbild loaded...");
            emit(FahrbildLoadedState(currentState.company, currentState.trainNumber, currentState.date));
          } else {
            Fimber.w("Ignoring response because is does not contain G2bReplyPayload");
          }
        } else {
          _validationFailed();
        }
      } else {
        Fimber.i("Ignoring message in state=${state.toString()}");
      }
    });
  }

  void _validationFailed() {
    if (state is BaseFahrbildState) {
      final currentState = state as BaseFahrbildState;
      Fimber.w("Validation failed for MQTT response");
      _mqttService.disconnect();
      emit(SelectingFahrbildState(
          company: currentState.company,
          trainNumber: currentState.trainNumber,
          errorCode: ErrorCode.sferaValidationFailed));
    }
  }

  void loadFahrbild() async {
    final currentState = state;
    if (currentState is SelectingFahrbildState) {
      final now = DateTime.now();
      final company = currentState.company;
      final trainNumber = currentState.trainNumber;
      if (company == null || trainNumber == null) {
        Fimber.i("company or trainNumber null");
        return;
      }

      emit(ConnectingState(company, trainNumber, now));
      if (await _mqttService.connect(company, _sferaTrain(trainNumber, now))) {
        _sendHandshakeRequest();
      } else {
        Fimber.w("Unable to load fahrbild because mqtt failed to connect");
        emit(SelectingFahrbildState(company: company, trainNumber: trainNumber, errorCode: ErrorCode.connectionFailed));
      }
    }
  }

  void _requestJourneyProfile() async {
    if (state is BaseFahrbildState) {
      final currentState = state as BaseFahrbildState;
      emit(RequestingJourneyState(currentState.company, currentState.trainNumber, currentState.date));

      var trainIdentification = TrainIdentification.create(
          otnId: OtnId.create(currentState.company, currentState.trainNumber, currentState.date));
      var jpRequest = JpRequest.create(trainIdentification);

      var messageHeader = MessageHeader.create(const Uuid().v4(), Format.sferaTimestamp(DateTime.now()),
          await DeviceIdInfo.getDeviceId(), "TMS", await DeviceIdInfo.getDeviceId(), "TMS",
          trainIdentification: trainIdentification);

      var sferaB2gRequestMessage =
          SferaB2gRequestMessage.create(messageHeader, b2gRequest: B2gRequest.create(jpRequest: jpRequest));
      Fimber.i("Sending journey request...");
      _mqttService.publishMessage(currentState.company, _sferaTrain(currentState.trainNumber, currentState.date),
          sferaB2gRequestMessage.buildDocument().toString());
    } else {
      Fimber.w("Requesting journey profile in wrong state");
    }
  }

  void _sendHandshakeRequest() async {
    if (state is BaseFahrbildState) {
      final currentState = state as BaseFahrbildState;
      final company = currentState.company;
      final train = currentState.trainNumber;
      final date = currentState.date;

      Fimber.i("Sending handshake request for company=$company train=${_sferaTrain(train, date)}");
      var handshakeRequest = HandshakeRequest.create([
        DasOperatingModesSupported.create(
            DasDrivingMode.goa1, DasArchitecture.boardAdviceCalculation, DasConnectivity.connected),
      ], relatedTrainRequestType: RelatedTrainRequestType.ownTrainAndRelatedTrains, statusReportsEnabled: true);

      var messageHeader = MessageHeader.create(const Uuid().v4(), Format.sferaTimestamp(DateTime.now()),
          await DeviceIdInfo.getDeviceId(), "TMS", await DeviceIdInfo.getDeviceId(), "TMS");

      var sferaB2gRequestMessage = SferaB2gRequestMessage.create(messageHeader, handshakeRequest: handshakeRequest);
      emit(RequestingHandshakeState(company, train, date));
      _mqttService.publishMessage(company, _sferaTrain(train, date), sferaB2gRequestMessage.buildDocument().toString());
    } else {
      Fimber.w("Requesting handshake in wrong state");
    }
  }

  String _sferaTrain(String trainNumber, DateTime date) {
    return "${Format.sferaDate(date)}_$trainNumber";
  }

  void updateTrainNumber(String? trainNumber) {
    if (state is SelectingFahrbildState) {
      emit(SelectingFahrbildState(trainNumber: trainNumber, company: (state as SelectingFahrbildState).company, errorCode: (state as SelectingFahrbildState).errorCode));
    }
  }

  void updateCompany(String? company) {
    if (state is SelectingFahrbildState) {
      emit(SelectingFahrbildState(trainNumber: (state as SelectingFahrbildState).trainNumber, company: company, errorCode: (state as SelectingFahrbildState).errorCode));
    }
  }

  @override
  Future<void> close() {
    mqttStreamSubscription?.cancel();
    return super.close();
  }
}

extension ContextBlocExtension on BuildContext {
  FahrbildCubit get fahrbildCubit => read<FahrbildCubit>();
}
