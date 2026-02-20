package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.TrainCharacteristicsIdentification;
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

/**
 * @see <a href="https://uic.org/events/uic-irs-90940-edition-2-sfera-protocol">IRS 90940 - Ed. 2</a>
 */
@Service
public class SferaMessageCreator {

    @Value("${sfera.company-code}")
    String companyCode;

    @Value("${sfera.version}")
    String sferaVersion;

    @Value("${sfera.source-device}")
    String sourceDevice;

    @Value("${sfera.recipient}")
    String sferaRecipient;

    public SFERAB2GRequestMessage createHandshakeRequestMessage(TrainIdentification trainIdentification) {
        SFERAB2GRequestMessage b2gRequestMessage = new SFERAB2GRequestMessage();
        b2gRequestMessage.setMessageHeader(createMessageHeader(trainIdentification));
        b2gRequestMessage.setHandshakeRequest(createHandshakeRequest());
        return b2gRequestMessage;
    }

    private HandshakeRequest createHandshakeRequest() {
        HandshakeRequest handshakeRequest = new HandshakeRequest();
        DASModesComplexType dasModes = new DASModesComplexType();
        dasModes.setDASArchitecture(DASArchitecture.BOARD_ADVICE_CALCULATION);
        dasModes.setDASConnectivity(DASConnectivity.STANDALONE);
        dasModes.setDASDrivingMode(DASDrivingMode.INACTIVE);
        handshakeRequest.getDASOperatingModesSupporteds().add(dasModes);
        return handshakeRequest;
    }

    public SFERAB2GRequestMessage createJpRequestMessage(TrainIdentification trainIdentification) {
        SFERAB2GRequestMessage b2gRequestMessage = new SFERAB2GRequestMessage();
        b2gRequestMessage.setMessageHeader(createMessageHeader(trainIdentification));
        B2GRequest b2gRequest = new B2GRequest();
        b2gRequest.getJPRequests().add(trainIdentification.toJpRequest());
        b2gRequestMessage.setB2GRequest(b2gRequest);
        return b2gRequestMessage;
    }

    public SFERAB2GRequestMessage createSpRequestMessage(TrainIdentification trainIdentification, Set<SegmentProfileIdentification> spIds) {
        SFERAB2GRequestMessage b2gRequestMessage = new SFERAB2GRequestMessage();
        b2gRequestMessage.setMessageHeader(createMessageHeader(trainIdentification));
        B2GRequest b2gRequest = new B2GRequest();
        List<SPRequest> spRequests = spIds.stream().map(SegmentProfileIdentification::toSpRequest).toList();
        b2gRequest.getSPRequests().addAll(spRequests);
        b2gRequestMessage.setB2GRequest(b2gRequest);
        return b2gRequestMessage;
    }

    public SFERAB2GRequestMessage createTcRequest(TrainIdentification trainIdentification, Set<TrainCharacteristicsIdentification> tcIds) {
        SFERAB2GRequestMessage b2gRequestMessage = new SFERAB2GRequestMessage();
        b2gRequestMessage.setMessageHeader(createMessageHeader(trainIdentification));
        B2GRequest b2gRequest = new B2GRequest();
        List<TCRequest> tcRequests = tcIds.stream().map(TrainCharacteristicsIdentification::toTcRequest).toList();
        b2gRequest.getTCRequests().addAll(tcRequests);
        b2gRequestMessage.setB2GRequest(b2gRequest);
        return b2gRequestMessage;
    }

    public SFERAB2GEventMessage createSessionTermination(TrainIdentification trainIdentification) {
        MessageHeader header = createMessageHeader(trainIdentification);
        SFERAB2GEventMessage b2gEventMessage = new SFERAB2GEventMessage();
        b2gEventMessage.setMessageHeader(header);
        B2GEventPayload b2gEventPayload = new B2GEventPayload();
        b2gEventPayload.setSessionTermination(new SessionTermination());
        b2gEventMessage.setB2GEventPayload(b2gEventPayload);
        return b2gEventMessage;
    }

    private MessageHeader createMessageHeader(TrainIdentification trainIdentification) {
        Sender sender = new Sender();
        sender.setValue(trainIdentification.company().getValue());
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
