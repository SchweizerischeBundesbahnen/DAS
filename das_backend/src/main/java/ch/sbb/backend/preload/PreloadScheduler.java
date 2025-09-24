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

    @Scheduled(fixedDelayString = "${preload.fetch-interval-ms}")
    public void fetchAndStore() {
        // TODO: TMS-VAD anbinden und echte Deltas holen
        List<JourneyProfile> jps = List.of();
        List<SegmentProfile> sps = List.of();
        List<TrainCharacteristics> tcs = List.of();

        if (!jps.isEmpty() || !sps.isEmpty() || !tcs.isEmpty()) {
            storageService.save(jps, sps, tcs);
        }
    }

    @Scheduled(
        fixedDelayString = "${preload.cleanup-interval-ms}",
        initialDelayString = "${preload.cleanup-initial-delay-ms}"
    )
    public void cleanupOldZips() {
        storageService.cleanUp();
    }
}
