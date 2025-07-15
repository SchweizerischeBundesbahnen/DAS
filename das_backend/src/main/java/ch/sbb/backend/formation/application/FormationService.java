package ch.sbb.backend.formation.application;

import ch.sbb.backend.admin.domain.settings.CompanyRepository;
import ch.sbb.backend.formation.infrastructure.TrainFormationRunRepository;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class FormationService {

    private final TrainFormationRunRepository trainFormationRunRepository;
    private final CompanyRepository companyRepository;

    public FormationService(TrainFormationRunRepository trainFormationRunRepository, CompanyRepository companyRepository) {
        this.trainFormationRunRepository = trainFormationRunRepository;
        this.companyRepository = companyRepository;
    }

    public void save(List<TrainFormationRunEntity> trainFormationRunEntities) {
        for (TrainFormationRunEntity trainFormationRunEntity : trainFormationRunEntities) {
            if (companyRepository.existsByCodeRics(trainFormationRunEntity.getCompany())) {
                trainFormationRunRepository.save(trainFormationRunEntity);
            }
        }
    }
}
