package ch.sbb.backend.formation.domain;

import ch.sbb.backend.formation.domain.model.TrainFormationRun;

public interface TrainFormationService {

    void processTrainFormationRun(TrainFormationRun trainFormationRun);
}
