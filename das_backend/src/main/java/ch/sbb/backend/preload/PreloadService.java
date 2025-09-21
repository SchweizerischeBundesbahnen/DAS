package ch.sbb.backend.preload;

import ch.sbb.backend.adapters.sfera.model.v0201.HandshakeRequest;
import ch.sbb.backend.adapters.sfera.model.v0201.JPRequest;
import ch.sbb.backend.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.MessageHeader;
import ch.sbb.backend.adapters.sfera.model.v0201.SFERAB2GEventMessage;
import ch.sbb.backend.adapters.sfera.model.v0201.SFERAB2GRequestMessage;
import ch.sbb.backend.adapters.sfera.model.v0201.SFERAG2BReplyMessage;
import ch.sbb.backend.adapters.sfera.model.v0201.SPRequest;
import ch.sbb.backend.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.SegmentProfileReference;
import ch.sbb.backend.adapters.sfera.model.v0201.TCRequest;
import ch.sbb.backend.adapters.sfera.model.v0201.TrainCharacteristics;
import ch.sbb.backend.adapters.sfera.model.v0201.TrainCharacteristicsRef;
import ch.sbb.backend.preload.xml.XmlHelper;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.eclipse.paho.mqttv5.common.MqttMessage;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class PreloadService {

    public static final int MAX_MQTT_REPLY_TIMEOUT_MS = 5000;
    private static final String clientId = "das_preload"; // UUID.randomUUID()
    private static final String sferaVersion = "2";
    private static final List<String> TRAIN_NUMBERS = List.of("1513", "1670", "1671", "1672", "1809", "2266", "7318", "15154", "19240", "T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10",
        "T11", "T12", "T13", "T14", "T15", "T16", "T17", "T18", "T20", "T21", "T22", "T23", "T24", "T24", "T9999");
    private final PahoMqttClient mqttService;
    private final SferaMessageCreator sferaMessageCreator;
    private final XmlHelper xmlHelper;
    private final PreloadStorageService storageService;
    private final ConcurrentMap<String, CompletableFuture<SFERAG2BReplyMessage>> pending = new ConcurrentHashMap<>();
    private final List<JourneyProfile> jps = new ArrayList<>();
    private final List<SegmentProfile> sps = new ArrayList<>();
    private final List<TrainCharacteristics> tcs = new ArrayList<>();
    @Value("${sfera.topic-prefix}")
    private String topicPrefix;

    public PreloadService(PahoMqttClient mqttService, SferaMessageCreator sferaMessageCreator, XmlHelper xmlHelper, PreloadStorageService storageService) {
        this.mqttService = mqttService;
        this.sferaMessageCreator = sferaMessageCreator;
        this.xmlHelper = xmlHelper;
        this.storageService = storageService;
    }

    //    every 5 minutes
    //    @Scheduled(fixedRate = 300000)
    @Scheduled(initialDelay = 1000)
    public void scheduled() {
        try {
            mqttService.connect();
        } catch (MqttException e) {
            log.error("Could not connect to MQTT broker", e);
        }
        for (String trainNumber : TRAIN_NUMBERS) {
            try {
                preload("1085", trainNumber, LocalDate.now());
            } catch (Exception e) {
                log.error("Preload for train {} failed", trainNumber, e);
            }
        }
        storageService.save(jps, sps, tcs);

        mqttService.disconnect();
        jps.clear();
        sps.clear();
        tcs.clear();
    }

    private void preload(String companyCode, String operationalTrainnumber, LocalDate startDate) throws ExecutionException, InterruptedException {

        mqttService.subscribe(g2bTopic(companyCode, operationalTrainnumber, startDate), (topic, message) -> receive(message));
        String b2gTopic = b2gTopic(companyCode, operationalTrainnumber, startDate);

        SFERAG2BReplyMessage handshakeReply = sendRequest(b2gTopic, createHandshakeRequest(), MAX_MQTT_REPLY_TIMEOUT_MS).get();
        if (handshakeReply.getHandshakeAcknowledgement() == null) {
            throw new IllegalStateException("Handshake not acknowledged!");
        }
        SFERAG2BReplyMessage jpResponse = sendRequest(b2gTopic, createJpRequest(companyCode, operationalTrainnumber, startDate), MAX_MQTT_REPLY_TIMEOUT_MS).get();
        if (jpResponse.getG2BReplyPayload() == null || jpResponse.getG2BReplyPayload().getJourneyProfile() == null) {
            throw new IllegalStateException("No Journey Profile received!");
        }
        List<JourneyProfile> journeyProfiles = jpResponse.getG2BReplyPayload().getJourneyProfile();
        jps.addAll(journeyProfiles);

        List<SegmentProfileReference> spReferences = journeyProfiles.stream().flatMap(jp -> jp.getSegmentProfileReference().stream()).toList();
        List<TrainCharacteristicsRef> tcReferences = spReferences.stream().flatMap(spRef -> spRef.getTrainCharacteristicsRef().stream()).toList();

        CompletableFuture<Void> spRequest;
        if (!spReferences.isEmpty()) {
            spRequest = sendRequest(b2gTopic, createSpRequest(spReferences), MAX_MQTT_REPLY_TIMEOUT_MS)
                .thenAccept(reply -> {
                    if (reply.getG2BReplyPayload() == null || reply.getG2BReplyPayload().getSegmentProfile() == null) {
                        throw new IllegalStateException("No Segment Profile received!");
                    }
                    sps.addAll(reply.getG2BReplyPayload().getSegmentProfile());
                });
        } else {
            spRequest = CompletableFuture.completedFuture(null);
        }

        CompletableFuture<Void> tcRequest;
        if (!tcReferences.isEmpty()) {
            tcRequest = sendRequest(b2gTopic, createTcRequest(tcReferences), MAX_MQTT_REPLY_TIMEOUT_MS)
                .thenAccept(reply -> {
                    if (reply.getG2BReplyPayload() == null || reply.getG2BReplyPayload().getTrainCharacteristics() == null) {
                        throw new IllegalStateException("No Train Characteristics received!");
                    }
                    tcs.addAll(reply.getG2BReplyPayload().getTrainCharacteristics());
                });
        } else {
            tcRequest = CompletableFuture.completedFuture(null);
        }
        // when sp and tc are done terminate session
        CompletableFuture.allOf(spRequest, tcRequest).get();
        log.info("Preload for train {} completed: jps={}, sps={}, tcs={}", operationalTrainnumber, jps.size(), sps.size(), tcs.size());
        //        todo
        //        sendRequest(b2gTopic, createTermination(), MAX_MQTT_REPLY_TIMEOUT_MS);
    }

    private String g2bTopic(String companyCode, String operationalTrainNumber, LocalDate startDate) {
        return String.format("%s90940/%s/G2B/%s/%s_%s/%s", topicPrefix, sferaVersion, companyCode, operationalTrainNumber, startDate, clientId);
    }

    private String b2gTopic(String companyCode, String operationalTrainNumber, LocalDate startDate) {
        return String.format("%s90940/%s/B2G/%s/%s_%s/%s", topicPrefix, sferaVersion, companyCode, operationalTrainNumber, startDate, clientId);
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

    CompletableFuture<SFERAG2BReplyMessage> sendRequest(String requestTopic, Object payload, long timeoutMs) {
        String messageId = switch (payload) {
            case SFERAB2GRequestMessage msg -> msg.getMessageHeader().getMessageID();
            case SFERAB2GEventMessage msg -> msg.getMessageHeader().getMessageID();
            default -> throw new IllegalArgumentException("Unexpected payload type: " + payload.getClass());
        };

        CompletableFuture<SFERAG2BReplyMessage> future = new CompletableFuture<>();
        pending.put(messageId, future);
        mqttService.publish(requestTopic, xmlHelper.toString(payload));
        ScheduledExecutorService ses = Executors.newSingleThreadScheduledExecutor();
        ses.schedule(() -> {
            CompletableFuture<SFERAG2BReplyMessage> f = pending.remove(messageId);
            if (f != null && !f.isDone()) {
                f.completeExceptionally(new TimeoutException("No reply within " + timeoutMs + "ms"));
            }
            ses.shutdown();
        }, timeoutMs, TimeUnit.MILLISECONDS);

        return future;
    }

    private SFERAB2GEventMessage createTermination() {
        MessageHeader header = sferaMessageCreator.createMessageHeader(UUID.randomUUID());
        return sferaMessageCreator.createSferaSessionTerminationEventMessage(header);
    }

    private SFERAB2GRequestMessage createSpRequest(List<SegmentProfileReference> spReferences) {
        MessageHeader header = sferaMessageCreator.createMessageHeader(UUID.randomUUID());
        List<SPRequest> spRequests = sferaMessageCreator.createSpRequests(spReferences);
        return sferaMessageCreator.createSferaRequestMessage(header, spRequests);
    }

    private SFERAB2GRequestMessage createHandshakeRequest() {
        MessageHeader header = sferaMessageCreator.createMessageHeader(UUID.randomUUID());
        HandshakeRequest handshakeRequest = sferaMessageCreator.createSferaHandshakeRequest();
        return sferaMessageCreator.createSferaHsRequestMessage(header, handshakeRequest);
    }

    private SFERAB2GRequestMessage createJpRequest(String companyCode, String operationalTrainnumber, LocalDate startDate) {
        MessageHeader header = sferaMessageCreator.createMessageHeader(UUID.randomUUID());
        JPRequest jpRequest = sferaMessageCreator.createJPRequest(companyCode, operationalTrainnumber, startDate);
        return sferaMessageCreator.createSferaJpRequestMessage(header, jpRequest);
    }

    private SFERAB2GRequestMessage createTcRequest(List<TrainCharacteristicsRef> tcReferences) {
        MessageHeader header = sferaMessageCreator.createMessageHeader(UUID.randomUUID());
        List<TCRequest> tcRequests = sferaMessageCreator.createTcRequests(tcReferences);
        return sferaMessageCreator.createSferaTcRequestMessage(header, tcRequests);
    }

}
