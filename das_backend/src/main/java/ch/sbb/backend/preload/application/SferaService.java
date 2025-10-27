package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.domain.PreloadResult;
import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.SferaStore;
import ch.sbb.backend.preload.domain.TrainCharacteristicsIdentification;
import ch.sbb.backend.preload.domain.TrainIdentification;
import ch.sbb.backend.preload.infrastructure.PahoMqttClient;
import ch.sbb.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GEventMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GRequestMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAG2BReplyMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfileReference;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;

@Service
public class SferaService {

    private static final int MAX_MQTT_REPLY_TIMEOUT_MS = 5000;
    private static final String G2B = "G2B";
    private static final String B2G = "B2G";
    private static final String CLIENT_ID = UUID.randomUUID().toString();

    private final PahoMqttClient mqttClient;
    private final SferaMessageCreator sferaMessageCreator;
    private final XmlHelper xmlHelper;
    private final ConcurrentMap<String, CompletableFuture<SFERAG2BReplyMessage>> pending = new ConcurrentHashMap<>();
    private final SferaStore sferaStore;

    @Value("${sfera.sfera-major-version}")
    private String sferaVersion;

    @Value("${sfera.topic-prefix}")
    private String topicPrefix;

    public SferaService(PahoMqttClient mqttClient, SferaMessageCreator sferaMessageCreator, XmlHelper xmlHelper) {
        this.mqttClient = mqttClient;
        this.sferaMessageCreator = sferaMessageCreator;
        this.xmlHelper = xmlHelper;
        this.sferaStore = new SferaStore();
    }

    @Retryable
    PreloadResult preload(TrainIdentification trainIdentification) throws ExecutionException, InterruptedException {
        // todo unsubscribe in recovery or finally
        mqttClient.subscribe(topic(G2B, trainIdentification), (topic, message) -> receive(message));

        SFERAG2BReplyMessage handshakeReply = sendRequest(trainIdentification, sferaMessageCreator.createHandshakeRequestMessage()).get();
        if (handshakeReply.getHandshakeAcknowledgement() == null) {
            throw new IllegalStateException("Handshake not acknowledged!");
        }
        SFERAG2BReplyMessage jpResponse = sendRequest(trainIdentification, sferaMessageCreator.createJpRequestMessage(trainIdentification)).get();
        if (jpResponse.getG2BReplyPayload() == null || jpResponse.getG2BReplyPayload().getJourneyProfile() == null) {
            throw new IllegalStateException("No Journey Profile received!");
        }
        Set<JourneyProfile> journeyProfiles = new HashSet<>(jpResponse.getG2BReplyPayload().getJourneyProfile());

        Set<SegmentProfileReference> spRefs = journeyProfiles.stream()
            .flatMap(jp -> jp.getSegmentProfileReference().stream()).collect(Collectors.toSet());

        CompletableFuture<Set<SegmentProfile>> futureSps = requestSps(trainIdentification, spRefs);

        CompletableFuture<Set<TrainCharacteristics>> futureTcs = requestTcs(trainIdentification, spRefs);

        Set<SegmentProfile> segmentProfiles = futureSps.get();
        Set<TrainCharacteristics> trainCharacteristics = futureTcs.get();
        sendRequest(trainIdentification, sferaMessageCreator.createSessionTermination()).get();
        mqttClient.unsubscribe(topic(G2B, trainIdentification));

        return new PreloadResult(journeyProfiles, segmentProfiles, trainCharacteristics);
    }

    private CompletableFuture<Set<SegmentProfile>> requestSps(TrainIdentification trainId, Set<SegmentProfileReference> spRefs) {
        Set<SegmentProfile> segmentProfiles = new HashSet<>();
        Set<SegmentProfileIdentification> segmentProfilesToFetch = new HashSet<>();

        Set<SegmentProfileIdentification> allSpIds = spRefs.stream()
            .map(SegmentProfileIdentification::from)
            .collect(Collectors.toSet());

        allSpIds.forEach(spId -> {
            SegmentProfile segmentProfile = sferaStore.getSp(spId);
            if (segmentProfile != null) {
                segmentProfiles.add(segmentProfile);
            } else {
                segmentProfilesToFetch.add(spId);
            }
        });

        if (!segmentProfilesToFetch.isEmpty()) {
            return sendRequest(trainId, sferaMessageCreator.createSpRequestMessage(segmentProfilesToFetch))
                .thenApply(reply -> {
                    if (reply.getG2BReplyPayload() == null || reply.getG2BReplyPayload().getSegmentProfile() == null) {
                        throw new IllegalStateException("No Segment Profile received!");
                    }
                    List<SegmentProfile> fetched = reply.getG2BReplyPayload().getSegmentProfile();
                    sferaStore.addSps(fetched);
                    segmentProfiles.addAll(fetched);
                    return segmentProfiles;
                });
        } else {
            return CompletableFuture.completedFuture(segmentProfiles);
        }
    }

    private CompletableFuture<Set<TrainCharacteristics>> requestTcs(TrainIdentification trainId, Set<SegmentProfileReference> spRefs) {
        Set<TrainCharacteristics> trainCharacteristics = new HashSet<>();
        Set<TrainCharacteristicsIdentification> trainCharacteristicsToFetch = new HashSet<>();

        Set<TrainCharacteristicsIdentification> allTcIds = spRefs.stream()
            .flatMap(spRef -> spRef.getTrainCharacteristicsRef().stream())
            .map(TrainCharacteristicsIdentification::from)
            .collect(Collectors.toSet());

        allTcIds.forEach(tcRef -> {
            TrainCharacteristics trainCharacteristic = sferaStore.getTc(tcRef);
            if (trainCharacteristic != null) {
                trainCharacteristics.add(trainCharacteristic);
            } else {
                trainCharacteristicsToFetch.add(tcRef);
            }
        });

        if (!trainCharacteristicsToFetch.isEmpty()) {

            return sendRequest(trainId, sferaMessageCreator.createTcRequest(trainCharacteristicsToFetch))
                .thenApply(reply -> {
                    if (reply.getG2BReplyPayload() == null || reply.getG2BReplyPayload().getTrainCharacteristics() == null) {
                        throw new IllegalStateException("No Train Characteristics received!");
                    }
                    List<TrainCharacteristics> fetched = reply.getG2BReplyPayload().getTrainCharacteristics();
                    sferaStore.addTcs(fetched);
                    trainCharacteristics.addAll(fetched);
                    return trainCharacteristics;
                });
        } else {
            return CompletableFuture.completedFuture(trainCharacteristics);
        }
    }

    private String topic(String direction, TrainIdentification trainIdentification) {
        return String.format("%s90940/%s/%s/%s/%s_%s/%s", topicPrefix, sferaVersion, direction, trainIdentification.companyCode(), trainIdentification.operationalTrainNumber(),
            trainIdentification.startDate(),
            CLIENT_ID);
    }

    private void receive(MqttMessage mqttMessage) {
        Object replyMessage = xmlHelper.xmlToObject(mqttMessage.toString());
        if (Objects.requireNonNull(replyMessage) instanceof SFERAG2BReplyMessage reply) {
            CompletableFuture<SFERAG2BReplyMessage> future = pending.remove(reply.getMessageHeader().getCorrelationID());
            if (future != null) {
                future.complete(reply);
            }
        } else {
            throw new IllegalStateException("Unexpected value: " + replyMessage);
        }
    }

    private CompletableFuture<SFERAG2BReplyMessage> sendRequest(TrainIdentification trainId, Object payload) {
        String messageId = switch (payload) {
            case SFERAB2GRequestMessage msg -> msg.getMessageHeader().getMessageID();
            case SFERAB2GEventMessage msg -> msg.getMessageHeader().getMessageID();
            default -> throw new IllegalArgumentException("Unexpected payload type: " + payload.getClass());
        };

        CompletableFuture<SFERAG2BReplyMessage> future = new CompletableFuture<>();
        pending.put(messageId, future);
        mqttClient.publish(topic(B2G, trainId), xmlHelper.toString(payload));
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ses.schedule(() -> {
            CompletableFuture<SFERAG2BReplyMessage> f = pending.remove(messageId);
            if (f != null && !f.isDone()) {
                f.completeExceptionally(new TimeoutException("No reply within " + MAX_MQTT_REPLY_TIMEOUT_MS + "ms"));
            }
            ses.shutdown();
        }, MAX_MQTT_REPLY_TIMEOUT_MS, TimeUnit.MILLISECONDS);

        return future;
    }
}

