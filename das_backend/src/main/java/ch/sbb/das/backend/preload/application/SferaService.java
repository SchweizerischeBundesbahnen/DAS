package ch.sbb.das.backend.preload.application;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.das.backend.preload.domain.PreloadResult;
import ch.sbb.das.backend.preload.domain.PreloadResult.Unavailable;
import ch.sbb.das.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.preload.domain.SferaStore;
import ch.sbb.das.backend.preload.domain.TrainCharacteristicsIdentification;
import ch.sbb.das.backend.preload.infrastructure.PahoMqttClient;
import ch.sbb.das.backend.preload.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.preload.infrastructure.SegmentProfileMissingException;
import ch.sbb.das.backend.preload.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.preload.sfera.model.v0400.B2GMessageResponse.Result;
import ch.sbb.das.backend.preload.sfera.model.v0400.ErrorComplexType;
import ch.sbb.das.backend.preload.sfera.model.v0400.G2BReplyPayload;
import ch.sbb.das.backend.preload.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.preload.sfera.model.v0400.JourneyProfile.JPStatus;
import ch.sbb.das.backend.preload.sfera.model.v0400.SFERAB2GEventMessage;
import ch.sbb.das.backend.preload.sfera.model.v0400.SFERAB2GRequestMessage;
import ch.sbb.das.backend.preload.sfera.model.v0400.SFERAG2BReplyMessage;
import ch.sbb.das.backend.preload.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.preload.sfera.model.v0400.TrainCharacteristics;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
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
import org.jetbrains.annotations.NotNull;
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
    private final PreloadedSegmentProfileRepository preloadedSegmentProfileRepository;

    @Value("${sfera.major-version}")
    private String sferaMajorVersion;

    @Value("${sfera.topic-prefix}")
    private String topicPrefix;

    public SferaService(PahoMqttClient mqttClient, SferaMessageCreator sferaMessageCreator, XmlHelper xmlHelper, PreloadedSegmentProfileRepository preloadedSegmentProfileRepository) {
        this.mqttClient = mqttClient;
        this.sferaMessageCreator = sferaMessageCreator;
        this.xmlHelper = xmlHelper;
        this.sferaStore = new SferaStore();
        this.preloadedSegmentProfileRepository = preloadedSegmentProfileRepository;
    }

    @Recover
    private PreloadResult recoverPreload(Exception ex, TrainIdentification trainId) {
        try {
            return terminateSessionWithResult(trainId, new PreloadResult.Error("Preload failed after " + MAX_RETRIES + " attempts", ex));
        } catch (InterruptedException | ExecutionException | MqttException e) {
            return new PreloadResult.Error("Preload failed after " + MAX_RETRIES + " attempts and failed to terminate session", e);
        }
    }

    @Retryable(maxAttempts = MAX_RETRIES, retryFor = {ExecutionException.class, InterruptedException.class, MqttException.class}, listeners = "customRetryListener")
    PreloadResult preload(TrainIdentification trainId, Map<SegmentProfileIdentification, SegmentProfile> segmentProfilesMap) throws ExecutionException, InterruptedException, MqttException {
        mqttClient.subscribe(createTopic(G2B, trainId), (topic, message) -> receive(message));

        SFERAG2BReplyMessage handshakeReply = sendRequest(trainId, sferaMessageCreator.createHandshakeRequestMessage(trainId)).get();
        if (handshakeReply.getDASHandshakeAcknowledgement() == null) {
            if (isG2bError(handshakeReply.getG2BReplyPayload())) {
                String errors = extractG2bError(handshakeReply.getG2BReplyPayload());
                throw new IllegalStateException("Handshake request G2B error: " + errors);
            }
            throw new IllegalStateException("Handshake not acknowledged!");
        }
        SFERAG2BReplyMessage jpResponse = sendRequest(trainId, sferaMessageCreator.createJpRequestMessage(trainId)).get();
        if (jpResponse.getG2BReplyPayload() == null || jpResponse.getG2BReplyPayload().getJourneyProfiles() == null || jpResponse.getG2BReplyPayload().getJourneyProfiles().size() != 1) {
            if (isG2bError(jpResponse.getG2BReplyPayload())) {
                String errors = extractG2bError(jpResponse.getG2BReplyPayload());
                return terminateSessionWithResult(trainId, new PreloadResult.Error("JP request G2B error: " + errors));
            }
            return terminateSessionWithResult(trainId, new PreloadResult.Error("Expected exactly one Journey Profile but was none or multiple"));
        }
        JourneyProfile jp = jpResponse.getG2BReplyPayload().getJourneyProfiles().getFirst();

        if (JPStatus.UNAVAILABLE.equals(jp.getJPStatus())) {
            return terminateSessionWithResult(trainId, new Unavailable());
        }

        if (!JPStatus.VALID.equals(jp.getJPStatus())) {
            return terminateSessionWithResult(trainId, new PreloadResult.Error("Unexpected JPStatus: " + jp.getJPStatus()));
        }

        Set<SegmentProfileIdentification> spIds = jp.getSegmentProfileReferences().stream().map(SegmentProfileIdentification::from).collect(Collectors.toSet());
        spIds.removeIf(segmentProfilesMap::containsKey);

        List<SegmentProfile> segmentProfiles;
        try {
            segmentProfiles = requestSpsUntilComplete(trainId, spIds);
        } catch (SegmentProfileMissingException e) {
            return terminateSessionWithResult(trainId, new PreloadResult.Error(e.getMessage()));
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
        // todo send when vad has implemented
        // sendRequest(trainId, sferaMessageCreator.createSessionTermination(trainId)).get();
        mqttClient.unsubscribe(createTopic(G2B, trainId));
        return result;
    }

    private List<SegmentProfile> requestSpsUntilComplete(TrainIdentification trainId, Set<SegmentProfileIdentification> spIds)
        throws ExecutionException, InterruptedException, MqttException, SegmentProfileMissingException {

        List<SegmentProfile> allSegmentProfiles = new ArrayList<>();
        Set<SegmentProfileIdentification> missingSps = calculateMissingSegmentProfiles(spIds);

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

        if (!missingSps.isEmpty()) {
            throw new SegmentProfileMissingException("Not all Segment Profiles could be fetched after " + MAX_RETRIES + " attempts. Missing: " + missingSps);
        }
        return allSegmentProfiles;
    }

    public void connect() {
        mqttClient.connect(CLIENT_ID);
    }

    private CompletableFuture<Set<SegmentProfile>> requestSps(TrainIdentification trainId, Set<SegmentProfileIdentification> missingSps) throws MqttException {
        Set<SegmentProfile> segmentProfiles = new HashSet<>();

        if (!missingSps.isEmpty()) {
            return sendRequest(trainId, sferaMessageCreator.createSpRequestMessage(trainId, missingSps))
                .thenApply(reply -> {
                    if (reply.getG2BReplyPayload() == null || reply.getG2BReplyPayload().getSegmentProfiles() == null) {
                        if (isG2bError(reply.getG2BReplyPayload())) {
                            String errors = extractG2bError(reply.getG2BReplyPayload());
                            throw new IllegalStateException("SP request G2B error: " + errors);
                        }
                        throw new IllegalStateException("No SP(s) received!");
                    }
                    List<SegmentProfile> fetched = reply.getG2BReplyPayload().getSegmentProfiles();
                    segmentProfiles.addAll(fetched);
                    return segmentProfiles;
                });
        } else {
            return CompletableFuture.completedFuture(segmentProfiles);
        }
    }

    @NotNull
    private Set<SegmentProfileIdentification> calculateMissingSegmentProfiles(Set<SegmentProfileIdentification> spIds) {
        Set<String> spIdVersionSet = spIds.stream().map(SegmentProfileIdentification::toIdVersionString).collect(Collectors.toSet());
        Set<String> preloadedSpIdVersionSet = preloadedSegmentProfileRepository.findAllBySpIdVersionIn(spIdVersionSet).stream().map(PreloadedSegmentProfileEntity::getSpIdVersion)
            .collect(Collectors.toSet());
        preloadedSegmentProfileRepository.updateLastSeenBySpIdVersion(DateTimeUtil.now(), preloadedSpIdVersionSet);

        return spIds.stream().filter(spId -> !preloadedSpIdVersionSet.contains(spId.toIdVersionString())).collect(Collectors.toSet());
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
                        if (isG2bError(reply.getG2BReplyPayload())) {
                            String errors = extractG2bError(reply.getG2BReplyPayload());
                            throw new IllegalStateException("TC request G2B error: " + errors);
                        }
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
        return String.format("%s90940/%s/%s/%s/%s_%s/%s", topicPrefix, sferaMajorVersion, direction, trainId.company().value(), trainId.operationalTrainNumber(),
            trainId.startDateTime().toLocalDate(), CLIENT_ID);
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

    private boolean isG2bError(G2BReplyPayload g2bReplyPayload) {
        return g2bReplyPayload != null && g2bReplyPayload.getG2BMessageResponse() != null && g2bReplyPayload.getG2BMessageResponse().getResult() == Result.ERROR;
    }

    private String extractG2bError(G2BReplyPayload g2bReplyPayload) {
        if (isG2bError(g2bReplyPayload) && g2bReplyPayload.getG2BMessageResponse().getG2BErrors() != null) {
            return g2bReplyPayload.getG2BMessageResponse().getG2BErrors().stream()
                .map(ErrorComplexType::getErrorCode)
                .collect(Collectors.joining(", "));
        } else {
            return "";
        }
    }

    public void disconnect() {
        mqttClient.disconnect();
    }
}

