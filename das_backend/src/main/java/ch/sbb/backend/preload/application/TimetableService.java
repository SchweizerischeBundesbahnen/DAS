package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.converter.TimetableConverter;
import ch.sbb.backend.preload.application.model.trainidentification.Train;
import ch.sbb.backend.preload.infrastructure.TrainRunDAO;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainKey;
import ch.sbb.backend.preload.infrastructure.model.train.TimetableTrainValue;
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

    private final TrainRunDAO trainRunDao;
    private final TimetableConverter timetableConverter;

    public TimetableService(TrainRunDAO trainRunDao, TimetableConverter timetableConverter) {
        this.trainRunDao = trainRunDao;
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

        trainRunDao.deleteAll(trainsToDelete);
        trainRunDao.upsertAllTrains(trainsToUpdate);
    }

    @Transactional
    public void deleteObsoleteData(LocalDate cutoffData) {
        trainRunDao.deleteAllOlderThan(cutoffData);
    }
}
