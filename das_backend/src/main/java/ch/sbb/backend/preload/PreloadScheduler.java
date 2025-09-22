package ch.sbb.backend.preload;

import ch.sbb.backend.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.TrainCharacteristics;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class PreloadScheduler {

    private final PreloadStorageService storageService;

    public PreloadScheduler(PreloadStorageService storageService) {
        this.storageService = storageService;
    }

    // Alle 5 Minuten (Default). Holt Daten
    @Scheduled(fixedDelayString = "${preload.fetchIntervalMs:300000}")
    public void fetchAndStore() {
        // TODO: TMS-VAD anbinden und echte Deltas holen
        List<JourneyProfile> jps = List.of();
        List<SegmentProfile> sps = List.of();
        List<TrainCharacteristics> tcs = List.of();

        if (!jps.isEmpty() || !sps.isEmpty() || !tcs.isEmpty()) {
            storageService.save(jps, sps, tcs);
        }
    }

    // Cleanup z. B. stündlich
    @Scheduled(fixedDelayString = "${preload.cleanupIntervalMs:3600000}", initialDelayString = "${preload.cleanupInitialDelayMs:60000}")
    public void cleanupOldZips() {
        storageService.cleanUp();
    }
}