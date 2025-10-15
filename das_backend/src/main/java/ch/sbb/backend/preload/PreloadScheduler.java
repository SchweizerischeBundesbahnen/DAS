package ch.sbb.backend.preload;

import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class PreloadScheduler {

    private final PreloadStorageService storageService;

    public PreloadScheduler(PreloadStorageService storageService) {
        this.storageService = storageService;
    }

    //    TODO: deactivated for now
    //    @Scheduled(fixedDelayString = "${preload.fetch-interval-ms}")
    public void fetchAndStore() {
        // TODO: TMS-VAD anbinden und echte Deltas holen
        List<JourneyProfile> jps = List.of();
        List<SegmentProfile> sps = List.of();
        List<TrainCharacteristics> tcs = List.of();

        storageService.save(jps, sps, tcs);
    }
}