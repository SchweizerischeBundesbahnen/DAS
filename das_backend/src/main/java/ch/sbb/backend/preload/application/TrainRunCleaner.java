package ch.sbb.backend.preload.application;

import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class TrainRunCleaner {

    @Value("${preload.trainCleanUp.days}")
    private int days;

    private final FpsZugService fpsZugService;

    public TrainRunCleaner(FpsZugService fpsZugService) {
        this.fpsZugService = fpsZugService;
    }

    public void cleanUpTrainRuns() {
        fpsZugService.deleteObsoleteData(LocalDate.now().minusDays(days));
    }
}
