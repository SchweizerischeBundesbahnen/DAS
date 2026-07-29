package ch.sbb.das.backend.cargo.api.v1.internal;

import ch.sbb.das.backend.cargo.api.v1.model.Formation;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import java.util.List;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

@Component
public class FormationMapper {

    private final FormationRunMapper formationRunMapper;

    public FormationMapper(FormationRunMapper formationRunMapper) {
        this.formationRunMapper = formationRunMapper;
    }

    public Formation toFormation(List<TrainFormationRunEntity> trainFormationRunEntities) {
        if (CollectionUtils.isEmpty(trainFormationRunEntities)) {
            throw new IllegalArgumentException("Train formation runs cannot be empty");
        }

        TrainFormationRunEntity firstEntity = trainFormationRunEntities.getFirst();
        return Formation.builder()
            .operationalTrainNumber(firstEntity.getOperationalTrainNumber())
            .operationalDay(firstEntity.getOperationalDay())
            .company(firstEntity.getCompany())
            .formationRuns(formationRunMapper.toFormationRuns(trainFormationRunEntities))
            .build();
    }
}
