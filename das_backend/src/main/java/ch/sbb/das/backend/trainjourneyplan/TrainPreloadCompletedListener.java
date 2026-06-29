package ch.sbb.das.backend.trainjourneyplan;

import lombok.extern.slf4j.Slf4j;
import org.springframework.modulith.events.ApplicationModuleListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
class TrainPreloadCompletedListener {

    private final TrainIdentificationService trainIdentificationService;

    TrainPreloadCompletedListener(TrainIdentificationService trainIdentificationService) {
        this.trainIdentificationService = trainIdentificationService;
    }

    @ApplicationModuleListener
    void onTrainPreloadCompleted(TrainPreloadCompletedEvent event) {
        int rowsUpdated = trainIdentificationService.savePreloadedTrainIds(event.trainIdentificationIds());
        log.info("Marked {} train identifications as preloaded", rowsUpdated);
    }
}
