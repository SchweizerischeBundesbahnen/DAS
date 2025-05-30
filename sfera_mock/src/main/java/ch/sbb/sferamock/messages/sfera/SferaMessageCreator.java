package ch.sbb.sferamock.messages.sfera;

import ch.sbb.sferamock.adapters.sfera.model.v0201.B2GMessageResponse.Result;
import ch.sbb.sferamock.adapters.sfera.model.v0201.DASOperatingModeSelected;
import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BError;
import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BEventPayload;
import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BMessageResponse;
import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BReplyPayload;
import ch.sbb.sferamock.adapters.sfera.model.v0201.HandshakeAcknowledgement;
import ch.sbb.sferamock.adapters.sfera.model.v0201.HandshakeReject;
import ch.sbb.sferamock.adapters.sfera.model.v0201.HandshakeRejectReason;
import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.MessageHeader;
import ch.sbb.sferamock.adapters.sfera.model.v0201.MultilingualTextComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.OTNIDComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.Recipient;
import ch.sbb.sferamock.adapters.sfera.model.v0201.RelatedTrainInformation;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAG2BEventMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAG2BReplyMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.Sender;
import ch.sbb.sferamock.adapters.sfera.model.v0201.TrainCharacteristics;
import ch.sbb.sferamock.adapters.sfera.model.v0201.TrainIdentificationComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.UnavailableDASOperatingModes;
import ch.sbb.sferamock.messages.common.XmlDateHelper;
import ch.sbb.sferamock.messages.model.OperationMode;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SferaMessageCreator {

    @Value("${sfera.company-code}")
    String companyCode;

    @Value("${sfera.sfera-version}")
    String sferaVersion;

    @Value("${sfera.source-device}")
    String sourceDevice;

    private static TrainIdentificationComplexType createTrainIdentification(TrainIdentification tid) {
        var result = new TrainIdentificationComplexType();
        var otnId = new OTNIDComplexType();
        otnId.setTeltsiOperationalTrainNumber(tid.operationalNumber());
        otnId.setTeltsiCompany(tid.companyCode().value());
        otnId.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(tid.date()));
        result.setOTNID(otnId);
        return result;
    }

    public SFERAG2BReplyMessage createJourneyProfileReplyMessage(JourneyProfile journeyProfile, MessageHeader header, TrainIdentification tid) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(header);
        var payload = new G2BReplyPayload();
        journeyProfile.setTrainIdentification(createTrainIdentification(tid));
        payload.getJourneyProfile().add(journeyProfile);
        result.setG2BReplyPayload(payload);
        return result;
    }

    public MessageHeader createOutgoingMessageHeader(UUID messageId, Optional<UUID> correlationId, TrainIdentification tid) {
        return createMessageHeader(messageId, tid, correlationId);
    }

    public MessageHeader createMessageHeader(UUID messageId, TrainIdentification tid) {
        return createMessageHeader(messageId, tid, Optional.empty());
    }

    public MessageHeader createMessageHeader(UUID messageId, TrainIdentification tid, Optional<UUID> correlationId) {
        var sender = new Sender();
        sender.setValue(companyCode);
        var recipient = new Recipient();

        var result = new MessageHeader();
        result.setSFERAVersion(sferaVersion);
        result.setSourceDevice(sourceDevice);
        result.setMessageID(messageId.toString());
        recipient.setValue(tid.companyCode().value());
        correlationId.map(UUID::toString).ifPresent(result::setCorrelationID);
        result.setSender(sender);
        result.setRecipient(recipient);
        result.setTimestamp(XmlDateHelper.toGregorianCalender(ZonedDateTime.now()));
        return result;
    }

    public HandshakeAcknowledgement createSferaHandshakeAcknowledgement(OperationMode.Connectivity dasConnectivity, OperationMode.Architecture architecture) {
        var result = new HandshakeAcknowledgement();
        DASOperatingModeSelected dasOperatingModeSelected = new DASOperatingModeSelected();
        dasOperatingModeSelected.setDASArchitecture(toSferaArchitecture(architecture));
        dasOperatingModeSelected.setDASConnectivity(toSferaConnectivity(dasConnectivity));
        result.setDASOperatingModeSelected(dasOperatingModeSelected);
        return result;
    }

    public SFERAG2BEventMessage createRelatedTrainInformation(G2BEventPayload eventPayload, MessageHeader header, TrainIdentification tid) {
        eventPayload.getRelatedTrainInformation().getOwnTrain().setTrainIdentification(createTrainIdentification(tid));
        return createEventMessage(eventPayload, header);
    }

    public SFERAG2BEventMessage createJourneyProfileEventMessage(G2BEventPayload eventPayload, MessageHeader header, TrainIdentification tid) {
        for (JourneyProfile journeyProfile : eventPayload.getJourneyProfile()) {
            journeyProfile.setTrainIdentification(createTrainIdentification(tid));
        }
        return createEventMessage(eventPayload, header);
    }

    public SFERAG2BEventMessage createEventMessage(G2BEventPayload eventPayload, MessageHeader header) {
        var result = new SFERAG2BEventMessage();
        result.setMessageHeader(header);
        result.setG2BEventPayload(eventPayload);
        return result;
    }

    private UnavailableDASOperatingModes.DASArchitecture toSferaArchitecture(OperationMode.Architecture architecture) {
        return switch (architecture) {
            case groundCalculation -> UnavailableDASOperatingModes.DASArchitecture.GROUND_ADVICE_CALCULATION;
            case boardCalculation -> UnavailableDASOperatingModes.DASArchitecture.BOARD_ADVICE_CALCULATION;
        };
    }

    private UnavailableDASOperatingModes.DASConnectivity toSferaConnectivity(OperationMode.Connectivity connectivity) {
        return switch (connectivity) {
            case connected -> UnavailableDASOperatingModes.DASConnectivity.CONNECTED;
            case standalone -> UnavailableDASOperatingModes.DASConnectivity.STANDALONE;
        };
    }

    public HandshakeReject createSferaHandshakeReject(HandshakeRejectReason rejectReason) {
        var result = new HandshakeReject();
        result.getHandshakeRejectReason().add(rejectReason);
        return result;
    }

    public SFERAG2BReplyMessage createSferaReplyMessage(MessageHeader header, HandshakeAcknowledgement acknowledgement) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(header);
        result.setHandshakeAcknowledgement(acknowledgement);
        return result;
    }

    public SFERAG2BReplyMessage createSferaReplyErrorMessage(MessageHeader header, String errorCode, Optional<String> additionalInfo) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(header);

        var messageResponse = new G2BMessageResponse();
        G2BError g2BError = new G2BError();
        g2BError.setErrorCode(errorCode);
        additionalInfo.ifPresent(value -> {
            var text = new MultilingualTextComplexType();
            text.setText(value);
            text.setLanguage("de");
            g2BError.getAdditionalInfo().add(text);
        });
        messageResponse.getG2BError().add(g2BError);
        messageResponse.setResult(Result.ERROR);

        var replyPayload = new G2BReplyPayload();
        replyPayload.setG2BMessageResponse(messageResponse);
        result.setG2BReplyPayload(replyPayload);
        return result;
    }

    public SFERAG2BReplyMessage createSferaReplyErrorMessage(MessageHeader header, String errorCode) {
        return createSferaReplyErrorMessage(header, errorCode, Optional.empty());
    }

    public SFERAG2BReplyMessage createSferaReplyMessage(MessageHeader messageHeader, HandshakeReject handshakeReject) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(messageHeader);
        result.setHandshakeReject(handshakeReject);
        return result;
    }

    public SFERAG2BReplyMessage createSegmentProfileReplyMessage(List<SegmentProfile> segmentProfiles, MessageHeader header) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(header);
        var payload = new G2BReplyPayload();
        payload.getSegmentProfile().addAll(segmentProfiles);
        result.setG2BReplyPayload(payload);
        return result;
    }

    public SFERAG2BReplyMessage createTrainCharacteristicsReplyMessage(List<TrainCharacteristics> trainCharacteristics, MessageHeader header) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(header);
        var payload = new G2BReplyPayload();
        payload.getTrainCharacteristics().addAll(trainCharacteristics);
        result.setG2BReplyPayload(payload);
        return result;
    }

    public SFERAG2BReplyMessage createRelatedTrainInformationReplyMessage(List<RelatedTrainInformation> relatedTrainInformations, MessageHeader header, TrainIdentification tid) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(header);
        var payload = new G2BReplyPayload();
        relatedTrainInformations.forEach(relatedTrainInformation -> relatedTrainInformation.getOwnTrain().setTrainIdentification(createTrainIdentification(tid)));
        payload.getRelatedTrainInformation().addAll(relatedTrainInformations);
        result.setG2BReplyPayload(payload);
        return result;
    }

    public SFERAG2BReplyMessage createOkMessage(MessageHeader header) {
        var result = new SFERAG2BReplyMessage();
        result.setMessageHeader(header);
        var response = new G2BMessageResponse();
        response.setResult(Result.OK);
        var payload = new G2BReplyPayload();
        payload.setG2BMessageResponse(response);
        result.setG2BReplyPayload(payload);
        return result;
    }
}
