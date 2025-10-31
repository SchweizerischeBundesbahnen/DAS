package ch.sbb.sferamock.messages.sfera;

import static org.springframework.util.MimeTypeUtils.APPLICATION_XML;

import ch.sbb.sferamock.adapters.sfera.model.v0300.G2BEventPayload;
import ch.sbb.sferamock.adapters.sfera.model.v0300.SFERAG2BEventMessage;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.RequestContext;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.stream.function.StreamBridge;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Service;

@Service
public class EventPublisher {

    private static final Logger log = LoggerFactory.getLogger(EventPublisher.class);
    private static final String SOLACE_BINDER = "solace";
    private final XmlHelper xmlHelper;
    private final StreamBridge streamBridge;
    private final SferaMessageCreator sferaMessageCreator;
    @Value("${spring.cloud.stream.bindings.publishEvent-out-0.destination}")
    private String[] publishDestinations;

    public EventPublisher(XmlHelper xmlHelper, StreamBridge streamBridge, SferaMessageCreator sferaMessageCreator) {
        this.xmlHelper = xmlHelper;
        this.streamBridge = streamBridge;
        this.sferaMessageCreator = sferaMessageCreator;
    }

    public void publishRelatedTrainInformation(G2BEventPayload eventPayload, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid());
        var event = sferaMessageCreator.createRelatedTrainInformation(eventPayload, header, requestContext.tid());
        publishEvent(event, requestContext);
    }

    public void publishJourneyProfile(G2BEventPayload eventPayload, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid());
        var event = sferaMessageCreator.createJourneyProfileEventMessage(eventPayload, header, requestContext.tid());
        publishEvent(event, requestContext);
    }

    public void publishEventPayload(G2BEventPayload eventPayload, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid());
        var event = sferaMessageCreator.createEventMessage(eventPayload, header);
        publishEvent(event, requestContext);
    }

    private void publishEvent(SFERAG2BEventMessage eventMessage, RequestContext requestContext) {
        String topic = SferaTopicHelper.getG2BEventTopic(publishDestinations, requestContext);
        log.info("Publishing Event Message to topic {}", topic);
        log.debug("message: {}", xmlHelper.toString(eventMessage));
        streamBridge.send(topic, SOLACE_BINDER, MessageBuilder
                .withPayload(eventMessage)
                .build(),
            APPLICATION_XML);
    }
}
