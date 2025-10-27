package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.TrainCharacteristicsIdentification;
import ch.sbb.backend.preload.domain.TrainIdentification;
import ch.sbb.backend.preload.infrastructure.xml.XmlDateHelper;
import ch.sbb.backend.preload.sfera.model.v0300.B2GEventPayload;
import ch.sbb.backend.preload.sfera.model.v0300.B2GRequest;
import ch.sbb.backend.preload.sfera.model.v0300.DASModesComplexType;
import ch.sbb.backend.preload.sfera.model.v0300.HandshakeRequest;
import ch.sbb.backend.preload.sfera.model.v0300.MessageHeader;
import ch.sbb.backend.preload.sfera.model.v0300.Recipient;
import ch.sbb.backend.preload.sfera.model.v0300.ReportedDASDrivingMode.DASDrivingMode;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GEventMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GRequestMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.Sender;
import ch.sbb.backend.preload.sfera.model.v0300.SessionTermination;
import ch.sbb.backend.preload.sfera.model.v0300.TCRequest;
import ch.sbb.backend.preload.sfera.model.v0300.UnavailableDASOperatingModes.DASArchitecture;
import ch.sbb.backend.preload.sfera.model.v0300.UnavailableDASOperatingModes.DASConnectivity;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;
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

    @Value("${sfera.recipient}")
    String sferaRecipient;

    public SFERAB2GRequestMessage createHandshakeRequestMessage() {
        SFERAB2GRequestMessage message = new SFERAB2GRequestMessage();
        message.setMessageHeader(createMessageHeader());
        message.setHandshakeRequest(createHandshakeRequest());
        return message;
    }

    private HandshakeRequest createHandshakeRequest() {
        HandshakeRequest handshakeRequest = new HandshakeRequest();
        DASModesComplexType dasMode = new DASModesComplexType();
        dasMode.setDASArchitecture(DASArchitecture.BOARD_ADVICE_CALCULATION);
        dasMode.setDASConnectivity(DASConnectivity.STANDALONE);
        dasMode.setDASDrivingMode(DASDrivingMode.INACTIVE);
        handshakeRequest.getDASOperatingModesSupported().add(dasMode);
        return handshakeRequest;
    }

    public SFERAB2GRequestMessage createJpRequestMessage(TrainIdentification trainIdentification) {
        SFERAB2GRequestMessage message = new SFERAB2GRequestMessage();
        message.setMessageHeader(createMessageHeader());
        B2GRequest b2GRequest = new B2GRequest();
        b2GRequest.getJPRequest().add(trainIdentification.toJpRequest());
        message.setB2GRequest(b2GRequest);
        return message;
    }

    public SFERAB2GRequestMessage createSpRequestMessage(Set<SegmentProfileIdentification> spIds) {
        SFERAB2GRequestMessage message = new SFERAB2GRequestMessage();
        message.setMessageHeader(createMessageHeader());
        B2GRequest b2GRequest = new B2GRequest();
        List<SPRequest> spRequests = spIds.stream().map(SegmentProfileIdentification::toSpRequest).toList();
        b2GRequest.getSPRequest().addAll(spRequests);
        message.setB2GRequest(b2GRequest);
        return message;
    }

    public SFERAB2GRequestMessage createTcRequest(Set<TrainCharacteristicsIdentification> tcIds) {
        SFERAB2GRequestMessage message = new SFERAB2GRequestMessage();
        message.setMessageHeader(createMessageHeader());
        B2GRequest b2GRequest = new B2GRequest();
        List<TCRequest> tcRequests = tcIds.stream().map(TrainCharacteristicsIdentification::toTcRequest).toList();
        b2GRequest.getTCRequest().addAll(tcRequests);
        message.setB2GRequest(b2GRequest);
        return message;
    }

    public SFERAB2GEventMessage createSessionTermination() {
        MessageHeader header = createMessageHeader();
        SFERAB2GEventMessage result = new SFERAB2GEventMessage();
        result.setMessageHeader(header);
        B2GEventPayload eventPayload = new B2GEventPayload();
        eventPayload.setSessionTermination(new SessionTermination());
        result.setB2GEventPayload(eventPayload);
        return result;
    }

    private MessageHeader createMessageHeader() {
        Sender sender = new Sender();
        sender.setValue(companyCode);
        Recipient recipient = new Recipient();
        recipient.setValue(sferaRecipient);
        MessageHeader header = new MessageHeader();
        header.setSFERAVersion(sferaVersion);
        header.setSourceDevice(sourceDevice);
        header.setMessageID(UUID.randomUUID().toString());
        header.setSender(sender);
        header.setRecipient(recipient);
        header.setTimestamp(XmlDateHelper.toGregorianCalender(OffsetDateTime.now()));
        return header;
    }

}
