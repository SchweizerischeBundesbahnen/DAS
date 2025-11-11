package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.domain.PreloadResult;
import ch.sbb.backend.preload.domain.TrainId;
import ch.sbb.backend.preload.infrastructure.PahoMqttClient;
import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.time.OffsetDateTime;
import java.util.HashSet;
import java.util.Set;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class PreloadScheduler {

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
    public void scheduledPreload() {
        log.info("Preload started");
        long startTime = System.currentTimeMillis();
        Set<JourneyProfile> jps = new HashSet<>();
        Set<SegmentProfile> sps = new HashSet<>();
        Set<TrainCharacteristics> tcs = new HashSet<>();

        mqttService.connect();
        // todo timestamp from s3 or cache to get only new trains (#1393)
        for (TrainId trainId : trainIdentificationsService.getNewTrainIdentifications(OffsetDateTime.now())) {
            try {
                // todo: "InterruptedException" and "ThreadDeath" should not be ignored (#1393)
                PreloadResult preload = sferaService.preload(trainId);
                jps.addAll(preload.jps());
                sps.addAll(preload.sps());
                tcs.addAll(preload.tcs());
            } catch (Exception e) {
                log.error("Preload for train {} failed", trainId, e);
            }
        }
        mqttService.disconnect();
        storageService.save(jps, sps, tcs);
        log.info("Preload ended in {} ms", System.currentTimeMillis() - startTime);
    }
}