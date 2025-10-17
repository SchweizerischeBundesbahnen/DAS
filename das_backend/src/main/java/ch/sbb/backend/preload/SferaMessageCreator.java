package ch.sbb.backend.preload;

import ch.sbb.backend.preload.sfera.model.v0300.B2GEventPayload;
import ch.sbb.backend.preload.sfera.model.v0300.B2GRequest;
import ch.sbb.backend.preload.sfera.model.v0300.DASModesComplexType;
import ch.sbb.backend.preload.sfera.model.v0300.HandshakeRequest;
import ch.sbb.backend.preload.sfera.model.v0300.JPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.MessageHeader;
import ch.sbb.backend.preload.sfera.model.v0300.OTNIDComplexType;
import ch.sbb.backend.preload.sfera.model.v0300.Recipient;
import ch.sbb.backend.preload.sfera.model.v0300.ReportedDASDrivingMode.DASDrivingMode;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GEventMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GRequestMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfileReference;
import ch.sbb.backend.preload.sfera.model.v0300.Sender;
import ch.sbb.backend.preload.sfera.model.v0300.SessionTermination;
import ch.sbb.backend.preload.sfera.model.v0300.TCRequest;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristicsRef;
import ch.sbb.backend.preload.sfera.model.v0300.TrainIdentificationComplexType;
import ch.sbb.backend.preload.sfera.model.v0300.UnavailableDASOperatingModes.DASArchitecture;
import ch.sbb.backend.preload.sfera.model.v0300.UnavailableDASOperatingModes.DASConnectivity;
import ch.sbb.backend.preload.xml.XmlDateHelper;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
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

    public JPRequest createJPRequest(String companyCode, String operationalTrainNumber, LocalDate startDate) {
        JPRequest result = new JPRequest();
        TrainIdentificationComplexType trainIdentification = new TrainIdentificationComplexType();
        OTNIDComplexType otnid = new OTNIDComplexType();
        otnid.setTeltsiCompany(companyCode);
        otnid.setTeltsiOperationalTrainNumber(operationalTrainNumber);
        otnid.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(startDate));
        trainIdentification.setOTNID(otnid);
        result.setTrainIdentification(trainIdentification);
        return result;
    }

    public List<TCRequest> createTcRequests(List<TrainCharacteristicsRef> tcRefs) {
        return tcRefs.stream()
            .map(tcRef -> {
                TCRequest result = new TCRequest();
                result.setTCID(tcRef.getTCID());
                result.setTCVersionMajor(tcRef.getTCVersionMajor());
                result.setTCVersionMinor(tcRef.getTCVersionMinor());
                result.setTCRUID(tcRef.getTCRUID());
                return result;
            })
            .toList();

    }

    HandshakeRequest createSferaHandshakeRequest() {
        HandshakeRequest result = new HandshakeRequest();
        DASModesComplexType dasMode = new DASModesComplexType();
        dasMode.setDASArchitecture(DASArchitecture.BOARD_ADVICE_CALCULATION);
        dasMode.setDASConnectivity(DASConnectivity.STANDALONE);
        dasMode.setDASDrivingMode(DASDrivingMode.INACTIVE);
        result.getDASOperatingModesSupported().add(dasMode);
        return result;
    }

    public MessageHeader createMessageHeader(UUID messageId) {
        Sender sender = new Sender();
        sender.setValue(companyCode);
        Recipient recipient = new Recipient();
        recipient.setValue(sferaRecipient);

        MessageHeader result = new MessageHeader();
        result.setSFERAVersion(sferaVersion);
        result.setSourceDevice(sourceDevice);
        result.setMessageID(messageId.toString());
        result.setSender(sender);
        result.setRecipient(recipient);
        result.setTimestamp(XmlDateHelper.toGregorianCalender(OffsetDateTime.now()));
        return result;
    }

    SFERAB2GRequestMessage createSferaJpRequestMessage(MessageHeader header, JPRequest jpRequest) {
        SFERAB2GRequestMessage result = new SFERAB2GRequestMessage();
        result.setMessageHeader(header);
        B2GRequest b2GRequest = new B2GRequest();
        b2GRequest.getJPRequest().add(jpRequest);
        result.setB2GRequest(b2GRequest);
        return result;
    }

    SFERAB2GRequestMessage createSferaTcRequestMessage(MessageHeader header, List<TCRequest> tcRequests) {
        SFERAB2GRequestMessage result = new SFERAB2GRequestMessage();
        result.setMessageHeader(header);
        B2GRequest b2GRequest = new B2GRequest();
        b2GRequest.getTCRequest().addAll(tcRequests);
        result.setB2GRequest(b2GRequest);
        return result;
    }

    SFERAB2GRequestMessage createSferaHsRequestMessage(MessageHeader header, HandshakeRequest handshakeRequest) {
        SFERAB2GRequestMessage result = new SFERAB2GRequestMessage();
        result.setMessageHeader(header);
        result.setHandshakeRequest(handshakeRequest);
        return result;
    }

    SFERAB2GRequestMessage createSferaRequestMessage(MessageHeader header, List<SPRequest> spRequests) {
        SFERAB2GRequestMessage result = new SFERAB2GRequestMessage();
        result.setMessageHeader(header);
        B2GRequest b2GRequest = new B2GRequest();
        b2GRequest.getSPRequest().addAll(spRequests);
        result.setB2GRequest(b2GRequest);
        return result;
    }

    public List<SPRequest> createSpRequests(List<SegmentProfileReference> spReferences) {
        return spReferences.stream()
            .map(spReference -> {
                SPRequest spRequest = new SPRequest();
                spRequest.setSPID(spReference.getSPID());
                spRequest.setSPVersionMajor(spReference.getSPVersionMajor());
                spRequest.setSPVersionMinor(spReference.getSPVersionMinor());
                spRequest.setSPZone(spReference.getSPZone());
                return spRequest;
            })
            .toList();
    }

    public SFERAB2GEventMessage createSferaSessionTerminationEventMessage(MessageHeader header) {
        SFERAB2GEventMessage result = new SFERAB2GEventMessage();
        result.setMessageHeader(header);
        B2GEventPayload eventPayload = new B2GEventPayload();
        eventPayload.setSessionTermination(new SessionTermination());
        result.setB2GEventPayload(eventPayload);
        return result;
    }
}
