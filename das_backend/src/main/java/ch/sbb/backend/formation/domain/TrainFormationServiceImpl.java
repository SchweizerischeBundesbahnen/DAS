package ch.sbb.backend.formation.domain;

import ch.sbb.backend.admin.domain.settings.CompanyService;
import ch.sbb.backend.formation.domain.model.TrainFormationRun;

public class TrainFormationServiceImpl implements TrainFormationService {

    private final TrainFormationRunRepository trainFormationRunRepository;
    private final CompanyService companyService;

    public TrainFormationServiceImpl(TrainFormationRunRepository trainFormationRunRepository, CompanyService companyService) {
        this.trainFormationRunRepository = trainFormationRunRepository;
        this.companyService = companyService;
    }

    @Override
    public void processTrainFormationRun(TrainFormationRun trainFormationRun) {
        //        todo check company exists
        //        if(companyService.existsByCodeRics(trainFormationRun))
        trainFormationRunRepository.save(trainFormationRun);
    }
}
