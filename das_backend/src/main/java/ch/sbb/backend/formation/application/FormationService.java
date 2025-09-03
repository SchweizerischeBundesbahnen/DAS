package ch.sbb.backend.formation.application;

import ch.sbb.backend.formation.infrastructure.TrainFormationRunRepository;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class FormationService {

    private final TrainFormationRunRepository trainFormationRunRepository;

    public FormationService(TrainFormationRunRepository trainFormationRunRepository) {
        this.trainFormationRunRepository = trainFormationRunRepository;
    }

    public void save(List<TrainFormationRunEntity> trainFormationRunEntities) {
        trainFormationRunRepository.saveAll(trainFormationRunEntities);
    }

    public List<TrainFormationRunEntity> findByTrainIdentifier(String operationalTrainNumber,
        LocalDate operationalDay,
        String company) {
        return trainFormationRunRepository.findByOperationalTrainNumberAndOperationalDayAndCompanyOrderByInspectionDateTime(
            operationalTrainNumber,
            operationalDay,
            company
        );
    }

    public void deleteByTrassenIdAndOperationalDay(String trassenId, LocalDate operationalDay) {
        trainFormationRunRepository.deleteByTrassenIdAndOperationalDay(trassenId, operationalDay);
    }
}
