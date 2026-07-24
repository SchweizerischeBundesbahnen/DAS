package ch.sbb.das.backend.cargo.api.v1.internal;

import ch.sbb.das.backend.cargo.api.v1.model.FormationRun;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class FormationRunMapper {

    public FormationRun toFormationRun(TrainFormationRunEntity trainFormationRunEntity) {
        return FormationRun.builder()
            .inspectionDateTime(trainFormationRunEntity.getInspectionDateTime())
            .tafTapLocationReferenceStart(trainFormationRunEntity.getTafTapLocationReferenceStart())
            .tafTapLocationReferenceEnd(trainFormationRunEntity.getTafTapLocationReferenceEnd())
            .trainCategoryCode(trainFormationRunEntity.getTrainCategoryCode())
            .brakedWeightPercentage(trainFormationRunEntity.getBrakedWeightPercentage())
            .tractionMaxSpeedInKmh(trainFormationRunEntity.getTractionMaxSpeedInKmh())
            .hauledLoadMaxSpeedInKmh(trainFormationRunEntity.getHauledLoadMaxSpeedInKmh())
            .formationMaxSpeedInKmh(trainFormationRunEntity.getFormationMaxSpeedInKmh())
            .tractionLengthInCm(trainFormationRunEntity.getTractionLengthInCm())
            .hauledLoadLengthInCm(trainFormationRunEntity.getHauledLoadLengthInCm())
            .formationLengthInCm(trainFormationRunEntity.getFormationLengthInCm())
            .tractionWeightInT(trainFormationRunEntity.getTractionWeightInT())
            .hauledLoadWeightInT(trainFormationRunEntity.getHauledLoadWeightInT())
            .formationWeightInT(trainFormationRunEntity.getFormationWeightInT())
            .tractionBrakedWeightInT(trainFormationRunEntity.getTractionBrakedWeightInT())
            .hauledLoadBrakedWeightInT(trainFormationRunEntity.getHauledLoadBrakedWeightInT())
            .formationBrakedWeightInT(trainFormationRunEntity.getFormationBrakedWeightInT())
            .tractionHoldingForceInHectoNewton(trainFormationRunEntity.getTractionHoldingForceInHectoNewton())
            .hauledLoadHoldingForceInHectoNewton(trainFormationRunEntity.getHauledLoadHoldingForceInHectoNewton())
            .formationHoldingForceInHectoNewton(trainFormationRunEntity.getFormationHoldingForceInHectoNewton())
            .brakePositionGForLeadingTraction(trainFormationRunEntity.getBrakePositionGForLeadingTraction())
            .brakePositionGForBrakeUnit1to5(trainFormationRunEntity.getBrakePositionGForBrakeUnit1to5())
            .brakePositionGForLoadHauled(trainFormationRunEntity.getBrakePositionGForLoadHauled())
            .simTrain(trainFormationRunEntity.getSimTrain())
            .additionalTractions(trainFormationRunEntity.getAdditionalTractions())
            .carCarrierVehicle(trainFormationRunEntity.getCarCarrierVehicle())
            .dangerousGoods(trainFormationRunEntity.getDangerousGoods())
            .vehiclesCount(trainFormationRunEntity.getVehiclesCount())
            .vehiclesWithBrakeDesignLlAndKCount(trainFormationRunEntity.getVehiclesWithBrakeDesignLAndLlAndKCount()) // todo: delete as soon as das_client v 0.49.0 released
            .vehiclesWithBrakeDesignLAndLlAndKCount(trainFormationRunEntity.getVehiclesWithBrakeDesignLAndLlAndKCount())
            .vehiclesWithBrakeDesignDCount(trainFormationRunEntity.getVehiclesWithBrakeDesignDCount())
            .vehiclesWithDisabledBrakesCount(trainFormationRunEntity.getVehiclesWithDisabledBrakesCount())
            .europeanVehicleNumberFirst(trainFormationRunEntity.getEuropeanVehicleNumberFirst())
            .europeanVehicleNumberLast(trainFormationRunEntity.getEuropeanVehicleNumberLast())
            .axleLoadMaxInKg(trainFormationRunEntity.getAxleLoadMaxInKg())
            .routeClass(trainFormationRunEntity.getRouteClass())
            .gradientUphillMaxInPermille(trainFormationRunEntity.getGradientUphillMaxInPermille())
            .gradientDownhillMaxInPermille(trainFormationRunEntity.getGradientDownhillMaxInPermille())
            .slopeMaxForHoldingForceMinInPermille(trainFormationRunEntity.getSlopeMaxForHoldingForceMinInPermille())
            .build();
    }

    public List<FormationRun> toFormationRuns(List<TrainFormationRunEntity> trainFormationRunEntities) {
        return trainFormationRunEntities.stream()
            .map(this::toFormationRun)
            .toList();
    }
}
