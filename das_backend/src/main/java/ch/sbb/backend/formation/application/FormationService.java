package ch.sbb.backend.formation.application;

import ch.sbb.backend.admin.domain.settings.CompanyService;
import ch.sbb.backend.formation.infrastructure.TrainFormationRunRepository;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class FormationService {

    private final TrainFormationRunRepository trainFormationRunRepository;
    private final CompanyService companyService;

    public FormationService(TrainFormationRunRepository trainFormationRunRepository, CompanyService companyService) {
        this.trainFormationRunRepository = trainFormationRunRepository;
        this.companyService = companyService;
    }

    public void save(List<TrainFormationRunEntity> trainFormationRunEntities) {
        for (TrainFormationRunEntity trainFormationRunEntity : trainFormationRunEntities) {
            if (companyService.existsByCodeRics(trainFormationRunEntity.getCompany())) {
                trainFormationRunRepository.save(trainFormationRunEntity);
            }
        }
    }

    public List<TrainFormationRunEntity> findByTrainIdentifier(
        String operationalTrainNumber,
        LocalDate operationalDay,
        String company
    ) {
        return trainFormationRunRepository.findByOperationalTrainNumberAndOperationalDayAndCompany(
            operationalTrainNumber,
            operationalDay,
            company
        );
    }
}
