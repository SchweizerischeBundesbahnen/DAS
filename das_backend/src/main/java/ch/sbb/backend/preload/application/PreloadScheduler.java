package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.backend.preload.domain.PreloadResult;
import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.TrainCharacteristicsIdentification;
import ch.sbb.backend.preload.infrastructure.PahoMqttClient;
import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class PreloadScheduler {

    private static final int PRELOAD_HOURS_BEFORE_DEPARTURE = 4;
    private final SferaService sferaService;
    private final PahoMqttClient mqttService;
    private final MockTrainIdentificationService trainIdentificationsService;
    private final StorageService storageService;

    public PreloadScheduler(SferaService sferaService, PahoMqttClient mqttService, MockTrainIdentificationService trainIdentificationsService, StorageService storageService) {
        this.sferaService = sferaService;
        this.mqttService = mqttService;
        this.trainIdentificationsService = trainIdentificationsService;
        this.storageService = storageService;
    }

    @Scheduled(cron = "${preload.fetch-cron}")
    @SchedulerLock(name = "preload", lockAtLeastFor = "10m")
    public void scheduledPreload() throws MqttException, ExecutionException, InterruptedException {
        log.info("Preload started");
        long startTime = System.currentTimeMillis();
        Map<TrainIdentification, JourneyProfile> jps = new HashMap<>();
        Map<SegmentProfileIdentification, SegmentProfile> sps = new HashMap<>();
        Map<TrainCharacteristicsIdentification, TrainCharacteristics> tcs = new HashMap<>();
        List<TrainIdentification> trainIdentifications = trainIdentificationsService.getNewTrainIdentifications(OffsetDateTime.now().plusHours(PRELOAD_HOURS_BEFORE_DEPARTURE))
            .stream().toList();
        mqttService.connect();
        for (TrainIdentification trainId : trainIdentifications) {
            PreloadResult preloadResult = sferaService.preload(trainId);
            switch (preloadResult) {
                case PreloadResult.Success(var successJp, var successSps, var successTcs) -> {
                    jps.put(trainId, successJp);
                    sps.putAll(successSps.stream().collect(Collectors.toMap(SegmentProfileIdentification::from, sp -> sp)));
                    tcs.putAll(successTcs.stream().collect(Collectors.toMap(TrainCharacteristicsIdentification::from, tc -> tc)));
                    log.info("Preload for train {} succeeded with {} sps and {} tcs", trainId, successSps.size(), successTcs.size());
                }
                case PreloadResult.Unavailable() -> log.info("Preload for train {} unavailable for now", trainId);
                case PreloadResult.Error(var message, Throwable ex) -> log.error("Preload for train {} failed with message: {}", trainId, message, ex);
            }
        }
        mqttService.disconnect();
        storageService.save(jps.values(), sps.values(), tcs.values());
        trainIdentificationsService.savePreloadedTrains(jps.keySet());
        log.info("Preload ended in {} ms", System.currentTimeMillis() - startTime);
    }
}
