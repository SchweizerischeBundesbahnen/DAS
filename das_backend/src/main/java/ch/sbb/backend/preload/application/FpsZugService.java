package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.converter.FpsZugConverter;
import ch.sbb.backend.preload.application.model.dailytrainrun.Train;
import ch.sbb.backend.preload.infrastructure.TrainRunDAO;
import ch.sbb.backend.preload.infrastructure.model.traindata.FpsInfraZugKey;
import ch.sbb.backend.preload.infrastructure.model.traindata.FpsInfraZugValue;
import com.fasterxml.jackson.core.JsonProcessingException;
import java.time.LocalDate;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class FpsZugService {

    public static final String UPDATE_EVENT_TYPE = "UPDATE";
    public static final String DELETE_EVENT_TYPE = "DELETE";

    private final TrainRunDAO trainRunDao;
    private final FpsZugConverter fpsZugConverter;

    public FpsZugService(TrainRunDAO trainRunDao, FpsZugConverter fpsZugConverter) {
        this.trainRunDao = trainRunDao;
        this.fpsZugConverter = fpsZugConverter;
    }

    @Transactional
    public void deleteOrSaveTrains(List<ConsumerRecord<FpsInfraZugKey, FpsInfraZugValue>> fpsZugRecords) {
        val trains = fpsZugConverter.convertFpsZugRecords(fpsZugRecords);
        if (trains.isEmpty()) {
            return;
        }

        List<Train> trainsToDelete = trains.stream()
            .filter(it -> it.getEventType().equals(DELETE_EVENT_TYPE))
            .toList();

        List<Train> trainsToUpdate = trains.stream()
            .filter(it -> it.getEventType().equals(UPDATE_EVENT_TYPE))
            .toList();

        trainRunDao.deleteAllTrains(trainsToDelete);
        trainRunDao.upsertAllTrains(trainsToUpdate);
        trainRunDao.deleteAllFromTrainRunDays(trains);
        trainRunDao.deleteAllFromTrainRun(trains);
        trainRunDao.insertTrainRunDays(trainsToUpdate);
        try {
            trainRunDao.insertTrainRuns(trainsToUpdate);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error writing TrainRunPoints as String", e);
        }
    }

    @Transactional
    public void deleteObsoleteData(LocalDate cutoffData) {
        trainRunDao.deleteAllTrainRunsOlderThan(cutoffData);
        trainRunDao.deleteTrainsWithPeriodOlderThan(cutoffData.getYear());
    }
}
