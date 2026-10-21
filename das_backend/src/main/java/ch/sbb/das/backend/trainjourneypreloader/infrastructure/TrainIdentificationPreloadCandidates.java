package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentificationService;
import ch.sbb.das.backend.trainjourneypreloader.application.PreloadCandidates;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Component;

/**
 * Preload candidates are the train identifications in the departure window that are not yet marked preloaded.
 */
@Component
public class TrainIdentificationPreloadCandidates implements PreloadCandidates {

    private final TrainIdentificationService trainIdentificationService;

    public TrainIdentificationPreloadCandidates(TrainIdentificationService trainIdentificationService) {
        this.trainIdentificationService = trainIdentificationService;
    }

    @Override
    public List<TrainIdentification> between(OffsetDateTime from, OffsetDateTime to) {
        return trainIdentificationService.getNewTrainIdentificationsBetween(from, to);
    }

    @Override
    public void markPreloaded(Set<Integer> trainIdentificationIds) {
        trainIdentificationService.savePreloadedTrainIds(trainIdentificationIds);
    }
}
