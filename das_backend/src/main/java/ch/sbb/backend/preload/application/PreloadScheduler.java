package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.model.trainidentification.TrainIdentification;
import ch.sbb.backend.preload.domain.PreloadResult;
import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.TrainCharacteristicsIdentification;
import ch.sbb.backend.preload.sfera.model.v0400.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0400.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0400.TrainCharacteristics;
import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.eclipse.paho.mqttv5.common.MqttException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class PreloadScheduler {

    /**
     * Due to infrastructure realtime handling of operating trains, real train runs get clear just a few hours earlier.
     */
    private static final int PRELOAD_HOURS_BEFORE_DEPARTURE = 4;

    @Value("${preload.storageCleanUp.hours}")
    private int cleanUpHours;

    private final SferaService sferaService;
    private final TrainIdentificationService trainIdentificationsService;
    private final StorageService storageService;

    public PreloadScheduler(SferaService sferaService, TrainIdentificationService trainIdentificationsService, StorageService storageService) {
        this.sferaService = sferaService;
        this.trainIdentificationsService = trainIdentificationsService;
        this.storageService = storageService;
    }

    @Scheduled(cron = "${preload.fetch-cron}")
    @SchedulerLock(name = "preload", lockAtLeastFor = "4m" /* must be shorter than cron-job */)
    public void scheduledPreload() throws MqttException, ExecutionException, InterruptedException {
        log.info("Preload started");
        long startTime = System.currentTimeMillis();
        Map<TrainIdentification, JourneyProfile> mapJourneyProfiles = new HashMap<>();
        Map<SegmentProfileIdentification, SegmentProfile> mapSegmentProfiles = new HashMap<>();
        Map<TrainCharacteristicsIdentification, TrainCharacteristics> mapTrainCharacteristics = new HashMap<>();
        List<TrainIdentification> trainIdentifications = trainIdentificationsService.getNewTrainIdentificationsBetween(OffsetDateTime.now().minusHours(PRELOAD_HOURS_BEFORE_DEPARTURE),
            OffsetDateTime.now().plusHours(PRELOAD_HOURS_BEFORE_DEPARTURE));
        sferaService.connect();
        for (TrainIdentification trainId : trainIdentifications) {
            PreloadResult preloadResult = sferaService.preload(trainId);
            switch (preloadResult) {
                case PreloadResult.Success(var successJp, var successSps, var successTcs) -> {
                    mapJourneyProfiles.put(trainId, successJp);
                    mapSegmentProfiles.putAll(successSps.stream().collect(Collectors.toMap(SegmentProfileIdentification::from, sp -> sp)));
                    mapTrainCharacteristics.putAll(successTcs.stream().collect(Collectors.toMap(TrainCharacteristicsIdentification::from, tc -> tc)));
                    log.info("Preload for train {} succeeded with {} sps and {} tcs", trainId, successSps.size(), successTcs.size());
                }
                case PreloadResult.Unavailable() -> log.info("Preload for train {} unavailable for now", trainId);
                case PreloadResult.Error(var message, Throwable ex) -> log.error("Preload for train {} failed with message: {}", trainId, message, ex);
            }
        }
        sferaService.disconnect();
        storageService.save(mapJourneyProfiles.values(), mapSegmentProfiles.values(), mapTrainCharacteristics.values());
        storageService.deleteAllBefore(OffsetDateTime.now().minusHours(cleanUpHours));
        trainIdentificationsService.savePreloadedTrains(mapJourneyProfiles.keySet());
        log.info("Preload with {} JPs of requested {} JPs ended in {} ms", mapJourneyProfiles.size(), trainIdentifications.size(), System.currentTimeMillis() - startTime);

    }

}
