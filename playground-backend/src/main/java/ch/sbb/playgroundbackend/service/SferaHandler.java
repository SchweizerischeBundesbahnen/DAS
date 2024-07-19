package ch.sbb.playgroundbackend.service;

import static ch.sbb.playgroundbackend.helper.XmlHelper.objectToXml;
import static ch.sbb.playgroundbackend.helper.XmlHelper.xmlToObject;

import com.solace.spring.cloud.stream.binder.messaging.SolaceHeaders;
import generated.SFERAB2GRequestMessage;
import generated.SFERAG2BReplyMessage;
import jakarta.xml.bind.JAXBException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;

@Component
public class SferaHandler {

    private static final Logger log = LoggerFactory.getLogger(SferaHandler.class);

    private final StaticSferaService staticSferaService;

    public String replyTopic;

    public SferaHandler(StaticSferaService staticSferaService) {
        this.staticSferaService = staticSferaService;
    }

    public String boardToGround(Message<String> message) {
        String inputTopic = message.getHeaders().get(SolaceHeaders.DESTINATION).toString();
        SFERAG2BReplyMessage replyMessage;

        this.replyTopic = replyTopic(inputTopic);

        SFERAB2GRequestMessage sferab2GRequestMessage;
        try {
            sferab2GRequestMessage = xmlToObject(message.getPayload(), SFERAB2GRequestMessage.class);
            log.info("B2G request received");
            replyMessage = request(sferab2GRequestMessage);
        } catch (JAXBException e) {
            log.error("Could not map xml to object", e);
            replyMessage = staticSferaService.invalidXmlError();
        }
        try {
            return objectToXml(replyMessage);
        } catch (JAXBException e) {
            log.error("Could not map object to xml", e);
            return null;
        }
    }

    private SFERAG2BReplyMessage request(SFERAB2GRequestMessage requestMessage) {

        if (requestMessage.getHandshakeRequest() != null) {
            log.info("Send handshakeAck");
            return staticSferaService.handshake();
            //      or HandshakeReject
            //      or Error
        } else if (requestMessage.getB2GRequest() != null) {
            return b2gRequest(requestMessage);
        }
        log.info("Send insufficient data");
        return staticSferaService.insufficientData();
    }

    private SFERAG2BReplyMessage b2gRequest(SFERAB2GRequestMessage requestMessage) {
        if (requestMessage.getB2GRequest().getJPRequest() != null && !requestMessage.getB2GRequest().getJPRequest().isEmpty()) {
            // assuming only one jp request
            var jpRequest = requestMessage.getB2GRequest().getJPRequest().getFirst();
            var requestedTrainNumber = jpRequest.getTrainIdentification().getOTNID().getOperationalTrainNumber();
            var jpResult = staticSferaService.journeyProfile(requestedTrainNumber);
            if (jpResult != null) {
                log.info("Send JP for trainId={}", requestedTrainNumber);
                return jpResult;
            } else {
                log.info("JP with trainId={} not available", requestedTrainNumber);
                return staticSferaService.notAvailableError();
            }
            // G2B_MessageResponse / result = “OK” no more recent JP
            //                    or result = “ERROR” / dataFirstAvailable
            //                    or result = “ERROR” / errorCode

        }
        if (requestMessage.getB2GRequest().getSPRequest() != null && !requestMessage.getB2GRequest().getSPRequest().isEmpty()) {
            log.info("Send static SP");
            return staticSferaService.segmentProfile();
        }
        if (requestMessage.getB2GRequest().getTCRequest() != null && !requestMessage.getB2GRequest().getTCRequest().isEmpty()) {
            log.info("Send static TC");
            return staticSferaService.trainCharcteristics();
        }
        //      combination of SP/TC/JP
        //      or C_DAS_C_AdviceRequest
        //      or PlaintextMessageRequest
        //      or ForceDrivingModeChangeRequest
        //      or PositionSpeedRequest

        log.info("b2g request not implemented");
        return staticSferaService.notImplementedError();
    }

    private String replyTopic(String topic) {
        log.info("new message on topic={}", topic);
        String[] topicParts = topic.split("/");
        String companyCode = topicParts[3];
        String trainIdentifier = topicParts[4];
        String clientId = topicParts[5];
        return "90940/2/G2B/" + companyCode + "/" + trainIdentifier + "/" + clientId;
    }
}
