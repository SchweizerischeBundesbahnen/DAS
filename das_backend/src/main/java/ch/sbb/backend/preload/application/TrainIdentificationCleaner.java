package ch.sbb.backend.preload.application;

import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class TrainIdentificationCleaner {

    @Value("${preload.trainCleanUp.days}")
    private int days;

    private final TimetableService timetableService;

    public TrainIdentificationCleaner(TimetableService timetableService) {
        this.timetableService = timetableService;
    }

    public void cleanUpTrainRuns() {
        timetableService.deleteObsoleteData(LocalDate.now().minusDays(days));
    }
}
