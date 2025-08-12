package ch.sbb.sferamock.messages.sfera;

import static org.springframework.util.MimeTypeUtils.APPLICATION_XML;

import ch.sbb.sferamock.adapters.sfera.model.v0201.HandshakeRejectReason;
import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.RelatedTrainInformation;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAG2BReplyMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.TrainCharacteristics;
import ch.sbb.sferamock.messages.common.SferaErrorCodes;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.OperationMode;
import ch.sbb.sferamock.messages.model.RequestContext;
import java.util.List;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.stream.function.StreamBridge;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Service;

@Service
public class ReplyPublisher {

    private static final Logger log = LoggerFactory.getLogger(ReplyPublisher.class);
    private static final String SOLACE_BINDER = "solace";
    private final XmlHelper xmlHelper;
    private final StreamBridge streamBridge;
    private final SferaMessageCreator sferaMessageCreator;
    @Value("${spring.cloud.stream.bindings.publishG2BReply-out-0.destination}")
    private String publishDestination;

    public ReplyPublisher(XmlHelper xmlHelper, StreamBridge streamBridge, SferaMessageCreator sferaMessageCreator) {
        this.xmlHelper = xmlHelper;
        this.streamBridge = streamBridge;
        this.sferaMessageCreator = sferaMessageCreator;
    }

    public void publishJourneyProfile(JourneyProfile journeyProfile, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid(), requestContext.incomingMessageId());
        var reply = sferaMessageCreator.createJourneyProfileReplyMessage(journeyProfile, header, requestContext.tid());
        publishReplyMessage(reply, requestContext);
    }

    public void publishSegmentProfile(List<SegmentProfile> segmentProfiles, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid(), requestContext.incomingMessageId());
        var reply = sferaMessageCreator.createSegmentProfileReplyMessage(segmentProfiles, header);
        publishReplyMessage(reply, requestContext);
    }

    public void publishTrainCharacteristics(List<TrainCharacteristics> trainCharacteristics, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid(), requestContext.incomingMessageId());
        var reply = sferaMessageCreator.createTrainCharacteristicsReplyMessage(trainCharacteristics, header);
        publishReplyMessage(reply, requestContext);
    }

    public void publishRelatedTrainInformations(List<RelatedTrainInformation> relatedTrainInformations, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid(), requestContext.incomingMessageId());
        var reply = sferaMessageCreator.createRelatedTrainInformationReplyMessage(relatedTrainInformations, header, requestContext.tid());
        publishReplyMessage(reply, requestContext);
    }

    public void publishHandshakeAcknowledge(OperationMode.Connectivity connectivity,
        OperationMode.Architecture architecture,
        RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid(), requestContext.incomingMessageId());
        var ack = sferaMessageCreator.createSferaHandshakeAcknowledgement(connectivity, architecture);
        var reply = sferaMessageCreator.createSferaReplyMessage(header, ack);
        publishReplyMessage(reply, requestContext);
    }

    public void publishHandshakeReject(HandshakeRejectReason rejectReason, RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid(), requestContext.incomingMessageId());
        var ack = sferaMessageCreator.createSferaHandshakeReject(rejectReason);
        var reply = sferaMessageCreator.createSferaReplyMessage(header, ack);
        publishReplyMessage(reply, requestContext);
    }

    public void publishOkMessage(RequestContext requestContext) {
        var header = sferaMessageCreator.createMessageHeader(UUID.randomUUID(), requestContext.tid(), requestContext.incomingMessageId());
        var reply = sferaMessageCreator.createOkMessage(header);
        publishReplyMessage(reply, requestContext);
    }

    public void publishErrorMessage(SferaErrorCodes code, RequestContext requestContext) {
        var replyMessageHeader = sferaMessageCreator.createOutgoingMessageHeader(UUID.randomUUID(),
            requestContext.incomingMessageId(),
            requestContext.tid());
        var replyMessage = sferaMessageCreator.createSferaReplyErrorMessage(replyMessageHeader, code.getCode());
        publishReplyMessage(replyMessage, requestContext);
    }

    private void publishReplyMessage(SFERAG2BReplyMessage replyMessage, RequestContext requestContext) {
        String topic = SferaTopicHelper.getG2BTopic(publishDestination, requestContext);
        log.info("Publishing Reply Message to topic {}", topic);
        log.debug("message: {}", xmlHelper.toString(replyMessage));
        streamBridge.send(topic, SOLACE_BINDER, MessageBuilder
                .withPayload(replyMessage)
                .build(),
            APPLICATION_XML);
    }
}
