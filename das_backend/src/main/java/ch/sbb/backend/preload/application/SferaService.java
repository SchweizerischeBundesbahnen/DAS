package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.backend.preload.domain.PreloadResult;
import ch.sbb.backend.preload.domain.PreloadResult.Unavailable;
import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.SferaStore;
import ch.sbb.backend.preload.domain.TrainCharacteristicsIdentification;
import ch.sbb.backend.preload.infrastructure.PahoMqttClient;
import ch.sbb.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile.JPStatus;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GEventMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GRequestMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAG2BReplyMessage;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.util.ArrayList;
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
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.retry.annotation.Recover;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class SferaService {

    private static final int MAX_MQTT_REPLY_TIMEOUT_MS = 5000;
    private static final int MAX_RETRIES = 3;
    private static final String G2B = "G2B";
    private static final String B2G = "B2G";
    private static final String CLIENT_ID = UUID.randomUUID().toString();

    private final PahoMqttClient mqttClient;
    private final SferaMessageCreator sferaMessageCreator;
    private final XmlHelper xmlHelper;
    private final ConcurrentMap<String, CompletableFuture<SFERAG2BReplyMessage>> pending = new ConcurrentHashMap<>();
    private final SferaStore sferaStore;

    @Value("${sfera.major-version}")
    private String sferaMajorVersion;

    @Value("${sfera.topic-prefix}")
    private String topicPrefix;

    public SferaService(PahoMqttClient mqttClient, SferaMessageCreator sferaMessageCreator, XmlHelper xmlHelper) {
        this.mqttClient = mqttClient;
        this.sferaMessageCreator = sferaMessageCreator;
        this.xmlHelper = xmlHelper;
        this.sferaStore = new SferaStore();
    }

    @Recover
    private PreloadResult recoverPreload(Exception ex, TrainIdentification trainId) {
        try {
            return terminateSessionWithResult(trainId, new PreloadResult.Error("Preload failed after " + MAX_RETRIES + " attempts", ex));
        } catch (InterruptedException | ExecutionException | MqttException e) {
            return new PreloadResult.Error("Preload failed after " + MAX_RETRIES + " attempts and failed to terminate session", e);
        }
    }

    @Retryable(maxAttempts = MAX_RETRIES, retryFor = {ExecutionException.class, InterruptedException.class, MqttException.class})
    PreloadResult preload(TrainIdentification trainId) throws ExecutionException, InterruptedException, MqttException {
        mqttClient.subscribe(createTopic(G2B, trainId), (topic, message) -> receive(message));

        SFERAG2BReplyMessage handshakeReply = sendRequest(trainId, sferaMessageCreator.createHandshakeRequestMessage(trainId)).get();
        if (handshakeReply.getHandshakeAcknowledgement() == null) {
            throw new IllegalStateException("Handshake not acknowledged!");
        }
        SFERAG2BReplyMessage jpResponse = sendRequest(trainId, sferaMessageCreator.createJpRequestMessage(trainId)).get();
        if (jpResponse.getG2BReplyPayload() == null || jpResponse.getG2BReplyPayload().getJourneyProfiles() == null || jpResponse.getG2BReplyPayload().getJourneyProfiles().size() != 1) {
            return new PreloadResult.Error("Expected exactly one Journey Profile but was none or multiple");
        }

        JourneyProfile jp = jpResponse.getG2BReplyPayload().getJourneyProfiles().getFirst();

        if (JPStatus.UNAVAILABLE.equals(jp.getJPStatus())) {
            return terminateSessionWithResult(trainId, new Unavailable());
        }

        if (!JPStatus.VALID.equals(jp.getJPStatus())) {
            return terminateSessionWithResult(trainId, new PreloadResult.Error("Unexpected JPStatus: " + jp.getJPStatus()));
        }

        Set<SegmentProfileIdentification> spIds = jp.getSegmentProfileReferences().stream().map(SegmentProfileIdentification::from).collect(Collectors.toSet());

        List<SegmentProfile> segmentProfiles = requestSpsUntilComplete(trainId, spIds);
        if (segmentProfiles.size() != spIds.size()) {
            return terminateSessionWithResult(trainId, new PreloadResult.Error("Not all Segment Profiles could be fetched"));
        }

        Set<TrainCharacteristicsIdentification> tcIds = jp.getSegmentProfileReferences().stream()
            .flatMap(spRef -> spRef.getTrainCharacteristicsReves().stream())
            .map(TrainCharacteristicsIdentification::from)
            .collect(Collectors.toSet());

        List<TrainCharacteristics> trainCharacteristics = requestTcs(trainId, tcIds).get();
        if (trainCharacteristics.size() != tcIds.size()) {
            return terminateSessionWithResult(trainId, new PreloadResult.Error("Not all Train Characteristics could be fetched"));
        }
        return terminateSessionWithResult(trainId, new PreloadResult.Success(jp, segmentProfiles, trainCharacteristics));
    }

    private PreloadResult terminateSessionWithResult(TrainIdentification trainId, PreloadResult result) throws InterruptedException, ExecutionException, MqttException {
        sendRequest(trainId, sferaMessageCreator.createSessionTermination(trainId)).get();
        mqttClient.unsubscribe(createTopic(G2B, trainId));
        return result;
    }

    private List<SegmentProfile> requestSpsUntilComplete(TrainIdentification trainId, Set<SegmentProfileIdentification> spIds) throws ExecutionException, InterruptedException, MqttException {
        List<SegmentProfile> allSegmentProfiles = new ArrayList<>();
        Set<SegmentProfileIdentification> missingSps = new HashSet<>(spIds);
        int lastMissingCount = missingSps.size();
        int noNewResultsCounter = 0;
        while (!missingSps.isEmpty() && noNewResultsCounter < MAX_RETRIES) {
            Set<SegmentProfile> segmentProfiles = requestSps(trainId, missingSps).get();
            missingSps.removeAll(segmentProfiles.stream().map(SegmentProfileIdentification::from).collect(Collectors.toSet()));
            if (lastMissingCount == missingSps.size()) {
                noNewResultsCounter++;
            } else {
                allSegmentProfiles.addAll(segmentProfiles);
            }
            lastMissingCount = missingSps.size();
        }
        return allSegmentProfiles;
    }

    private CompletableFuture<Set<SegmentProfile>> requestSps(TrainIdentification trainId, Set<SegmentProfileIdentification> spIds) throws MqttException {
        Set<SegmentProfile> segmentProfiles = new HashSet<>();
        Set<SegmentProfileIdentification> segmentProfilesToFetch = new HashSet<>();

        spIds.forEach(spId -> {
            SegmentProfile segmentProfile = sferaStore.getSp(spId);
            if (segmentProfile != null) {
                segmentProfiles.add(segmentProfile);
            } else {
                segmentProfilesToFetch.add(spId);
            }
        });

        if (!segmentProfilesToFetch.isEmpty()) {
            return sendRequest(trainId, sferaMessageCreator.createSpRequestMessage(trainId, segmentProfilesToFetch))
                .thenApply(reply -> {
                    if (reply.getG2BReplyPayload() == null || reply.getG2BReplyPayload().getSegmentProfiles() == null) {
                        throw new IllegalStateException("No Segment Profile received!");
                    }
                    List<SegmentProfile> fetched = reply.getG2BReplyPayload().getSegmentProfiles();
                    sferaStore.addSps(fetched);
                    segmentProfiles.addAll(fetched);
                    return segmentProfiles;
                });
        } else {
            return CompletableFuture.completedFuture(segmentProfiles);
        }
    }

    private CompletableFuture<List<TrainCharacteristics>> requestTcs(TrainIdentification trainId, Set<TrainCharacteristicsIdentification> tcIds) throws MqttException {
        List<TrainCharacteristics> trainCharacteristics = new ArrayList<>();
        Set<TrainCharacteristicsIdentification> trainCharacteristicsToFetch = new HashSet<>();

        tcIds.forEach(tcId -> {
            TrainCharacteristics trainCharacteristic = sferaStore.getTc(tcId);
            if (trainCharacteristic != null) {
                trainCharacteristics.add(trainCharacteristic);
            } else {
                trainCharacteristicsToFetch.add(tcId);
            }
        });

        if (!trainCharacteristicsToFetch.isEmpty()) {
            return sendRequest(trainId, sferaMessageCreator.createTcRequest(trainId, trainCharacteristicsToFetch))
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

    private String createTopic(String direction, TrainIdentification trainId) {
        return String.format("%s90940/%s/%s/%s/%s_%s/%s", topicPrefix, sferaMajorVersion, direction, trainId.company().getValue(), trainId.operationalTrainNumber(), trainId.startDate(), CLIENT_ID);
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

    private CompletableFuture<SFERAG2BReplyMessage> sendRequest(TrainIdentification trainId, Object payload) throws MqttException {
        String messageId = switch (payload) {
            case SFERAB2GRequestMessage msg -> msg.getMessageHeader().getMessageID();
            case SFERAB2GEventMessage msg -> msg.getMessageHeader().getMessageID();
            default -> throw new IllegalArgumentException("Unexpected payload type: " + payload.getClass());
        };

        CompletableFuture<SFERAG2BReplyMessage> future = new CompletableFuture<>();
        pending.put(messageId, future);
        mqttClient.publish(createTopic(B2G, trainId), xmlHelper.toString(payload));
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ses.schedule(() -> {
            CompletableFuture<SFERAG2BReplyMessage> pendingFuture = pending.remove(messageId);
            if (pendingFuture != null && !pendingFuture.isDone()) {
                pendingFuture.completeExceptionally(new TimeoutException("No reply within " + MAX_MQTT_REPLY_TIMEOUT_MS + "ms"));
            }
            ses.shutdown();
        }, MAX_MQTT_REPLY_TIMEOUT_MS, TimeUnit.MILLISECONDS);

        return future;
    }
}

