package ch.sbb.playgroundbackend.service;

import ch.sbb.playgroundbackend.helper.XmlHelper;
import generated.DASOperatingModeSelected;
import generated.G2BReplyPayload;
import generated.HandshakeAcknowledgement;
import generated.JourneyProfile;
import generated.SFERAB2GRequestMessage;
import generated.SFERAG2BReplyMessage;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SferaSession {

    private static final Logger log = LoggerFactory.getLogger(SferaSession.class);
    private static final String XML_RESOURCES_CLASSPATH = "classpath:sfera_example_messages/";

    public SFERAG2BReplyMessage request(SFERAB2GRequestMessage requestMessage) {
        SFERAG2BReplyMessage replyMessage = new SFERAG2BReplyMessage();

        if (requestMessage.getHandshakeRequest() != null) {
            replyMessage.setHandshakeAcknowledgement(handshakeRequest(requestMessage));
            // todo or HandshakeReject
            //      or Error
            log.info("Send handshakeAck correlationId={}", requestMessage.getMessageHeader().getCorrelationID());
        } else if (requestMessage.getB2GRequest() != null) {
            replyMessage.setG2BReplyPayload(b2gRequest(requestMessage));
        }
        return replyMessage;

    }

    private G2BReplyPayload b2gRequest(SFERAB2GRequestMessage requestMessage) {
        G2BReplyPayload replyPayload = new G2BReplyPayload();

        if (requestMessage.getB2GRequest().getJPRequest() != null) {
            replyPayload.getJourneyProfile().addAll(exampleJp());
            // todo or G2B_MessageResponse / result = “OK” no more recent JP
            //      or result = “ERROR” / dataFirstAvailable
            //      or result = “ERROR” / errorCode
            log.info("Send JP for correlationId={}", requestMessage.getMessageHeader().getCorrelationID());
        }
        // todo or TCRequest
        //      or SP Rquest
        //      or combination of SP/TC/JP
        //      or C_DAS_C_AdviceRequest
        //      or PlaintextMessageRequest
        //      or ForceDrivingModeChangeRequest
        //      or PositionSpeedRequest
        //

        return replyPayload;
    }

    private List<JourneyProfile> exampleJp() {
        String filePath = XML_RESOURCES_CLASSPATH + "SFERA_G2B_Reply_JP_request.xml";
        return XmlHelper.xmlFileToObject(filePath, SFERAG2BReplyMessage.class).getG2BReplyPayload().getJourneyProfile();
    }

    private HandshakeAcknowledgement handshakeRequest(SFERAB2GRequestMessage requestMessage) {
        HandshakeAcknowledgement handshakeAcknowledgement = new HandshakeAcknowledgement();
        DASOperatingModeSelected dasOperatingModeSelected = new DASOperatingModeSelected();
        dasOperatingModeSelected.setDASArchitecture("GroundAdviceCalculation");
        dasOperatingModeSelected.setDASConnectivity("Connected");
        handshakeAcknowledgement.setDASOperatingModeSelected(dasOperatingModeSelected);
        return handshakeAcknowledgement;
    }

}
