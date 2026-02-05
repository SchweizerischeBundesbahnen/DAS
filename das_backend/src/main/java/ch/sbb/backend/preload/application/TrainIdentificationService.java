package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.application.mapper.TrainRunMapper;
import ch.sbb.backend.preload.application.model.dailytrainrun.TrainIdentification;
import ch.sbb.backend.preload.infrastructure.TrainRunRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import lombok.val;
import org.springframework.stereotype.Service;

@Service
public class TrainIdentificationService {

    public TrainIdentificationService(TrainRunRepository trainRunRepository, TrainRunMapper trainRunMapper) {
        this.trainRunRepository = trainRunRepository;
        this.trainRunMapper = trainRunMapper;
    }

    private final TrainRunRepository trainRunRepository;

    private final TrainRunMapper trainRunMapper;

    public List<TrainIdentification> processDailyTrainRunRequest(OffsetDateTime startDateTime) {
        val trainRunEntities = trainRunRepository.findAllByStartDateBefore(startDateTime.toLocalDate());

        return trainRunEntities.stream()
            .map(trainRunMapper::readEntity)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .filter(trainIdentification -> trainIdentification.getDepartureTime().isBefore(startDateTime))
            .toList();
    }
}
