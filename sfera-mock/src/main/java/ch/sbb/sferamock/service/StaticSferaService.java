package ch.sbb.sferamock.service;

import ch.sbb.sferamock.helper.XmlHelper;
import generated.SFERAG2BReplyMessage;
import jakarta.xml.bind.JAXBException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Service;

@Service
public class StaticSferaService implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(StaticSferaService.class);

    private static final String XML_RESOURCES_CLASSPATH = "classpath:sfera_example_messages/";
    private static final Map<Object, String> files = new HashMap<>();

    static {
        files.put(ResponseType.HANDSHAKE, "SFERA_G2B_ReplyMessage_handshake.xml");
        files.put(ResponseType.SP, "SFERA_G2B_Reply_SP_request.xml");
        files.put(ResponseType.TC, "SFERA_G2B_Reply_TC_request.xml");
        files.put(ResponseType.NOT_IMPLEMENTED, "SFERA_G2B_ReplyMessage_error_notImplemented.xml");
        files.put(ResponseType.XML_ERROR, "SFERA_G2B_ReplyMessage_error_xmlSchema.xml");
        files.put(ResponseType.NOT_AVAILABLE, "SFERA_G2B_ReplyMessage_error_notAvailable.xml");
        files.put(ResponseType.INSUFFICIENT_DATA, "SFERA_G2B_ReplyMessage_error_insufficientData.xml");
        files.put("9358", "SFERA_G2B_Reply_JP_request_9358.xml");
        files.put("9232", "SFERA_G2B_Reply_JP_request_9232.xml");
        files.put("9310", "SFERA_G2B_Reply_JP_request_9310.xml");
        files.put("9315", "SFERA_G2B_Reply_JP_request_9315.xml");
    }

    private final Map<Object, SFERAG2BReplyMessage> b2gReplies = new HashMap<>();

    @Override
    public void run(ApplicationArguments args) {
        files.forEach((trainId, fileName) -> {
            String filePath = XML_RESOURCES_CLASSPATH + fileName;
            try {
                this.b2gReplies.put(trainId, XmlHelper.xmlFileToObject(filePath, SFERAG2BReplyMessage.class));
            } catch (IOException | JAXBException e) {
                log.error("failed to import static xml replies", e);
            }
        });
        log.info("imported {} static replies", this.b2gReplies.size());
    }

    public SFERAG2BReplyMessage journeyProfile(String trainId) {
        return b2gReplies.get(trainId);
    }

    public SFERAG2BReplyMessage handshake() {
        return b2gReplies.get(ResponseType.HANDSHAKE);
    }

    public SFERAG2BReplyMessage segmentProfile() {
        return b2gReplies.get(ResponseType.SP);
    }

    public SFERAG2BReplyMessage trainCharcteristics() {
        return b2gReplies.get(ResponseType.TC);
    }

    public SFERAG2BReplyMessage invalidXmlError() {
        return b2gReplies.get(ResponseType.XML_ERROR);
    }

    public SFERAG2BReplyMessage notImplementedError() {
        return b2gReplies.get(ResponseType.NOT_IMPLEMENTED);
    }

    public SFERAG2BReplyMessage notAvailableError() {
        return b2gReplies.get(ResponseType.NOT_AVAILABLE);
    }

    public SFERAG2BReplyMessage insufficientData() {
        return b2gReplies.get(ResponseType.INSUFFICIENT_DATA);
    }

    protected enum ResponseType {
        HANDSHAKE,
        SP,
        TC,
        NOT_IMPLEMENTED,
        XML_ERROR,
        NOT_AVAILABLE,
        INSUFFICIENT_DATA,
    }
}
