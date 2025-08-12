package ch.sbb.sferamock.messages.sfera;

import ch.sbb.sferamock.adapters.sfera.model.v0201.B2GRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0201.JPRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0201.RelatedTrainInformationRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAB2GEventMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAB2GReplyMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAB2GRequestMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SPRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0201.TCRequest;
import ch.sbb.sferamock.messages.common.SferaErrorCodes;
import ch.sbb.sferamock.messages.common.XmlDateHelper;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.CompanyCode;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.model.SegmentIdentification;
import ch.sbb.sferamock.messages.model.TrainCharacteristicsIdentification;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import ch.sbb.sferamock.messages.services.SferaApplicationService;
import com.solacesystems.jcsmp.impl.TopicImpl;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import javax.xml.transform.stream.StreamSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.Message;
import org.springframework.oxm.jaxb.Jaxb2Marshaller;
import org.springframework.stereotype.Component;

@Component
public class IncomingMessageAdapter {

    private static final Logger log = LoggerFactory.getLogger(IncomingMessageAdapter.class);

    private final XmlHelper xmlHelper;
    private final Jaxb2Marshaller jaxb2Marshaller;
    private final SferaApplicationService sferaApplicationService;
    private final MessageHeaderValidator messageHeaderValidator;
    private final ReplyPublisher replyPublisher;

    public IncomingMessageAdapter(XmlHelper xmlHelper, Jaxb2Marshaller jaxb2Marshaller, SferaApplicationService sferaApplicationService, MessageHeaderValidator messageHeaderValidator,
        ReplyPublisher replyPublisher) {
        this.xmlHelper = xmlHelper;
        this.jaxb2Marshaller = jaxb2Marshaller;
        this.sferaApplicationService = sferaApplicationService;
        this.messageHeaderValidator = messageHeaderValidator;
        this.replyPublisher = replyPublisher;
    }

    public void processIncomingMessage(Message<byte[]> message) {
        var messageHeaders = message.getHeaders();
        var topic = Objects.requireNonNull(messageHeaders.get("solace_destination", TopicImpl.class)).getName();
        Object payload;
        String xmlString = null;
        try {
            xmlString = new String(message.getPayload(), StandardCharsets.UTF_8);
            payload = unmarshallPayload(xmlString);
        } catch (Exception e) {
            var errorMessage = getRootMessage(e);
            publishXmlValidationErrorMessage(xmlString, errorMessage, RequestContext.fromTopic(topic));
            return;
        }
        switch (payload) {
            case SFERAB2GRequestMessage request -> processB2GRequest(request, topic);
            case SFERAB2GEventMessage event -> {
                var requestContext = RequestContext.fromTopic(topic, Optional.of(UUID.fromString(event.getMessageHeader().getMessageID())));
                log.info("Received SFERAB2GEventMessage on topic {}", topic);
                log.debug("message: {}", xmlHelper.toString(event));
                var validationMessage = messageHeaderValidator.validate(event.getMessageHeader(), requestContext.tid().companyCode().value());
                if (validationMessage.isPresent()) {
                    log.warn("Reject Message with error in message header");
                    replyPublisher.publishErrorMessage(validationMessage.get(), requestContext);
                    return;
                }
                if (event.getB2GEventPayload() != null && event.getB2GEventPayload().getSessionTermination() != null) {
                    sferaApplicationService.processSessionTermination(requestContext);
                }

            }
            case SFERAB2GReplyMessage reply -> {
                log.info("Received SFERAB2GReplyMessage on topic {}", topic);
                log.debug("message: {}", xmlHelper.toString(reply));
            }
            default -> log.error("Unknown xml message type received: {} xml string \"{}\"", payload.getClass(), xmlString);
        }
    }

    private void processB2GRequest(SFERAB2GRequestMessage request, String topic) {
        var requestContext = RequestContext.fromTopic(topic, Optional.of(UUID.fromString(request.getMessageHeader().getMessageID())));
        log.info("Received SFERAB2GRequestMessage on topic {}", topic);
        log.debug("message: {}", xmlHelper.toString(request));
        var validationMessage = messageHeaderValidator.validate(request.getMessageHeader(), requestContext.tid().companyCode().value());
        if (validationMessage.isPresent()) {
            log.warn("Reject Message with error in message header");
            replyPublisher.publishErrorMessage(validationMessage.get(), requestContext);
            return;
        }
        if (request.getHandshakeRequest() != null) {
            var handshakeRequest = request.getHandshakeRequest();
            sferaApplicationService.processHandshakeRequest(
                SferaToInternalConverters.convertOperationModes(handshakeRequest.getDASOperatingModesSupported()),
                nullSafeBoolean(handshakeRequest.isStatusReportsEnabled()),
                requestContext);
        } else {
            B2GRequest b2GRequest = request.getB2GRequest();
            if (b2GRequest != null && b2GRequest.getJPRequest() != null && b2GRequest.getJPRequest().size() == 1) {
                processJourneyProfileRequest(request.getB2GRequest().getJPRequest().get(0), requestContext);
                return;
            }
            if (b2GRequest != null && b2GRequest.getSPRequest() != null && !b2GRequest.getSPRequest().isEmpty()) {
                processSegmentProfileRequest(b2GRequest.getSPRequest(), requestContext);
                return;
            }
            if (b2GRequest != null && b2GRequest.getTCRequest() != null && !b2GRequest.getTCRequest().isEmpty()) {
                processTrainCharacteristicsRequest(b2GRequest.getTCRequest(), requestContext);
                return;
            }
            if (b2GRequest != null && b2GRequest.getRelatedTrainInformationRequest() != null && !b2GRequest.getRelatedTrainInformationRequest().isEmpty()) {
                processRelatedTrainInformationRequest(b2GRequest.getRelatedTrainInformationRequest(), requestContext);
                return;
            }
            log.warn("A B2G Request that is not a handshake should currently have exactly one jp or sp request. Request is ignored.");
        }
    }

    private Object unmarshallPayload(String xmlString) {
        return jaxb2Marshaller.unmarshal(new StreamSource(new StringReader(xmlString)));
    }

    private boolean nullSafeBoolean(Boolean value) {
        return value != null && value;
    }

    private String getRootMessage(Exception exception) {
        String message = exception.getMessage();
        Throwable cause = exception.getCause();
        while (cause != null) {
            message = cause.getMessage();
            cause = cause.getCause();
        }
        return message;
    }

    private void publishXmlValidationErrorMessage(String message, String errorMessage, RequestContext requestContext) {
        log.warn("Exception while unmarshalling message '{}': {}", message, errorMessage);
        replyPublisher.publishErrorMessage(SferaErrorCodes.XML_SCHEMA_VIOLATION, requestContext);
    }

    private void processJourneyProfileRequest(JPRequest jpRequest, RequestContext requestContext) {
        var otnId = jpRequest.getTrainIdentification().getOTNID();
        var tid = new TrainIdentification(new CompanyCode(otnId.getTeltsiCompany()), otnId.getTeltsiOperationalTrainNumber(), XmlDateHelper.toLocalDate(otnId.getTeltsiStartDate()));
        sferaApplicationService.processJourneyProfileRequest(tid, requestContext);
    }

    private void processSegmentProfileRequest(List<SPRequest> spRequests, RequestContext requestContext) {
        var segmentIdentifications = spRequests.stream().map(spRequest -> new SegmentIdentification(
            spRequest.getSPID(),
            spRequest.getSPVersionMajor(),
            spRequest.getSPVersionMinor(),
            new CompanyCode(spRequest.getSPZone().getIMID()))).toList();
        sferaApplicationService.processSegmentProfileRequest(segmentIdentifications, requestContext);
    }

    private void processTrainCharacteristicsRequest(List<TCRequest> tcRequests, RequestContext requestContext) {
        var trainCharacteristicsIdentifications = tcRequests.stream().map(tcRequest -> new TrainCharacteristicsIdentification(
            tcRequest.getTCID(),
            tcRequest.getTCVersionMajor(),
            tcRequest.getTCVersionMinor(),
            new CompanyCode(tcRequest.getTCRUID()))).toList();
        sferaApplicationService.processTrainCharacteristicsRequest(trainCharacteristicsIdentifications, requestContext);
    }

    private void processRelatedTrainInformationRequest(List<RelatedTrainInformationRequest> relatedTrainInformationRequests, RequestContext requestContext) {
        var trainIdentifications = relatedTrainInformationRequests.stream()
            .map(relatedTrainInformationRequest -> relatedTrainInformationRequest.getTrainIdentification().getOTNID())
            .map(otnId -> new TrainIdentification(new CompanyCode(otnId.getTeltsiCompany()), otnId.getTeltsiOperationalTrainNumber(), XmlDateHelper.toLocalDate(otnId.getTeltsiStartDate())))
            .toList();
        sferaApplicationService.processRelatedTrainInformationRequest(trainIdentifications, requestContext);
    }
}
