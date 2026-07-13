package ch.sbb.das.backend.trainjourneyplan.application;

import ch.sbb.das.backend.trainjourneyplan.application.converter.TimetableConverter;
import ch.sbb.das.backend.trainjourneyplan.application.model.trainidentification.Train;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.TrainIdentificationBatchWriter;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.train.TimetableTrainKey;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.train.TimetableTrainValue;
import java.time.LocalDate;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class TimetableService {

    public static final String UPDATE_EVENT_TYPE = "UPDATE";
    public static final String DELETE_EVENT_TYPE = "DELETE";

    private final TrainIdentificationBatchWriter trainIdentificationBatchWriter;
    private final TimetableConverter timetableConverter;

    public TimetableService(TrainIdentificationBatchWriter trainIdentificationBatchWriter, TimetableConverter timetableConverter) {
        this.trainIdentificationBatchWriter = trainIdentificationBatchWriter;
        this.timetableConverter = timetableConverter;
    }

    @Transactional
    public void deleteOrSaveTrains(List<ConsumerRecord<TimetableTrainKey, TimetableTrainValue>> records) {
        List<Train> trains = timetableConverter.convertRecords(records);
        if (trains.isEmpty()) {
            return;
        }

        List<Train> trainsToDelete = trains.stream()
            .filter(it -> it.getEventType().equals(DELETE_EVENT_TYPE))
            .toList();

        List<Train> trainsToUpdate = trains.stream()
            .filter(it -> it.getEventType().equals(UPDATE_EVENT_TYPE))
            .toList();

        trainIdentificationBatchWriter.deleteAll(trainsToDelete);
        trainIdentificationBatchWriter.upsertAllTrains(trainsToUpdate);
    }

    @Transactional
    public void deleteAllBefore(LocalDate cutoffDate) {
        trainIdentificationBatchWriter.deleteAllOlderThan(cutoffDate);
    }
}
