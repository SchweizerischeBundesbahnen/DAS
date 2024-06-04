package ch.sbb.playgroundbackend.service;

import static ch.sbb.playgroundbackend.helper.XmlHelper.objectToXml;
import static ch.sbb.playgroundbackend.helper.XmlHelper.xmlToObject;

import com.solace.spring.cloud.stream.binder.messaging.SolaceHeaders;
import generated.G2BError;
import generated.G2BMessageResponse;
import generated.G2BReplyPayload;
import generated.MessageHeader;
import generated.Recipient;
import generated.SFERAB2GRequestMessage;
import generated.SFERAG2BReplyMessage;
import generated.Sender;
import java.time.Instant;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.MessageHeaders;

public class SferaHandler {

    private static final Logger log = LoggerFactory.getLogger(SferaHandler.class);
    private static final String SFERA_VERSION = "2.01";
    private static final String SOURCE_DEVICE = "TMS";
    private static final String SENDER = "0085";

    private final String companyCode;
    private final String trainIdentifier;
    private final String clientId;

    public SferaHandler(MessageHeaders messageHeaders) {
        String topic = messageHeaders.get(SolaceHeaders.DESTINATION).toString();
        String[] topicParts = topic.split("/");
        if (topicParts.length != 6) {
            log.error("wrong topic format topic={}", topic);
        }
        this.companyCode = topicParts[3];
        this.trainIdentifier = topicParts[4];
        this.clientId = topicParts[5];
    }

    public MessageHeader header(String correlationId) {
        MessageHeader responseHeader = new MessageHeader();
        responseHeader.setSFERAVersion(SFERA_VERSION);
        responseHeader.setMessageID(UUID.randomUUID().toString());
        responseHeader.setTimestamp(Instant.now());
        responseHeader.setSourceDevice(SOURCE_DEVICE);
        responseHeader.setCorrelationID(correlationId);

        Recipient recipient = new Recipient();
        recipient.setValue(companyCode);
        responseHeader.setRecipient(recipient);
        Sender sender = new Sender();
        sender.setValue(SENDER);
        responseHeader.setSender(sender);
        return responseHeader;
    }

    public String boardToGround(String xmlPayload) {
        SFERAB2GRequestMessage sferab2GRequestMessage = xmlToObject(xmlPayload, SFERAB2GRequestMessage.class);
        SFERAG2BReplyMessage replyMessage;
        if (sferab2GRequestMessage == null) {
            replyMessage = invalidXmlError();
        } else {
            SferaSession session = new SferaSession();
            log.info("B2G request received companyCode={} trainIdentifier={} clientId={}", companyCode, trainIdentifier, clientId);
            replyMessage = session.request(sferab2GRequestMessage);
        }
        replyMessage.setMessageHeader(header(sferab2GRequestMessage.getMessageHeader().getMessageID()));
        return objectToXml(replyMessage);
    }

    private SFERAG2BReplyMessage invalidXmlError() {
        G2BError error = new G2BError();
        error.setErrorCode("13");
        error.setAdditionalInfo("XML Schema Violation");
        return errorReply(error);
    }

    private SFERAG2BReplyMessage notImplementedError() {
        G2BError error = new G2BError();
        error.setErrorCode("99");
        error.setAdditionalInfo("Not implemented yet!");
        return errorReply(error);
    }

    private SFERAG2BReplyMessage errorReply(G2BError error) {
        SFERAG2BReplyMessage replyMessage = new SFERAG2BReplyMessage();
        G2BReplyPayload replyPayload = new G2BReplyPayload();
        G2BMessageResponse messageResponse = new G2BMessageResponse();
        messageResponse.setResult("ERROR");
        messageResponse.getG2BError().add(error);
        replyPayload.setG2BMessageResponse(messageResponse);
        replyMessage.setG2BReplyPayload(replyPayload);
        return replyMessage;
    }

    public String replyTopic() {
        return "90940/2/G2B/" + companyCode + "/" + trainIdentifier + "/" + clientId;
    }
}
