package ch.sbb.das.backend.cargo.api.v1.internal;

import ch.sbb.das.backend.cargo.api.v1.model.FormationRun;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class FormationRunMapper {

    public FormationRun toFormationRun(TrainFormationRunEntity entity) {
        return FormationRun.builder()
            .inspectionDateTime(entity.getInspectionDateTime())
            .tafTapLocationReferenceStart(TafTapLocationReference.of(entity.getTafTapLocationUicStartCode()).locationCode())
            .tafTapLocationReferenceEnd(TafTapLocationReference.of(entity.getTafTapLocationUicEndCode()).locationCode())
            .trainCategoryCode(entity.getTrainCategoryCode())
            .brakedWeightPercentage(entity.getBrakedWeightPercentage())
            .tractionMaxSpeedInKmh(entity.getTractionMaxSpeedInKmh())
            .hauledLoadMaxSpeedInKmh(entity.getHauledLoadMaxSpeedInKmh())
            .formationMaxSpeedInKmh(entity.getFormationMaxSpeedInKmh())
            .tractionLengthInCm(entity.getTractionLengthInCm())
            .hauledLoadLengthInCm(entity.getHauledLoadLengthInCm())
            .formationLengthInCm(entity.getFormationLengthInCm())
            .tractionWeightInT(entity.getTractionWeightInT())
            .hauledLoadWeightInT(entity.getHauledLoadWeightInT())
            .formationWeightInT(entity.getFormationWeightInT())
            .tractionBrakedWeightInT(entity.getTractionBrakedWeightInT())
            .hauledLoadBrakedWeightInT(entity.getHauledLoadBrakedWeightInT())
            .formationBrakedWeightInT(entity.getFormationBrakedWeightInT())
            .tractionHoldingForceInHectoNewton(entity.getTractionHoldingForceInHectoNewton())
            .hauledLoadHoldingForceInHectoNewton(entity.getHauledLoadHoldingForceInHectoNewton())
            .formationHoldingForceInHectoNewton(entity.getFormationHoldingForceInHectoNewton())
            .brakePositionGForLeadingTraction(entity.getBrakePositionGForLeadingTraction())
            .brakePositionGForBrakeUnit1to5(entity.getBrakePositionGForBrakeUnit1to5())
            .brakePositionGForLoadHauled(entity.getBrakePositionGForLoadHauled())
            .simTrain(entity.getSimTrain())
            .additionalTractions(entity.getAdditionalTractions())
            .carCarrierVehicle(entity.getCarCarrierVehicle())
            .dangerousGoods(entity.getDangerousGoods())
            .vehiclesCount(entity.getVehiclesCount())
            .vehiclesWithBrakeDesignLlAndKCount(entity.getVehiclesWithBrakeDesignLAndLlAndKCount()) // todo: delete as soon as das_client v 0.49.0 released
            .vehiclesWithBrakeDesignLAndLlAndKCount(entity.getVehiclesWithBrakeDesignLAndLlAndKCount())
            .vehiclesWithBrakeDesignDCount(entity.getVehiclesWithBrakeDesignDCount())
            .vehiclesWithDisabledBrakesCount(entity.getVehiclesWithDisabledBrakesCount())
            .europeanVehicleNumberFirst(entity.getEuropeanVehicleNumberFirst())
            .europeanVehicleNumberLast(entity.getEuropeanVehicleNumberLast())
            .axleLoadMaxInKg(entity.getAxleLoadMaxInKg())
            .routeClass(entity.getRouteClass())
            .gradientUphillMaxInPermille(entity.getGradientUphillMaxInPermille())
            .gradientDownhillMaxInPermille(entity.getGradientDownhillMaxInPermille())
            .slopeMaxForHoldingForceMinInPermille(entity.getSlopeMaxForHoldingForceMinInPermille())
            .build();
    }

    public List<FormationRun> toFormationRuns(List<TrainFormationRunEntity> trainFormationRunEntities) {
        return trainFormationRunEntities.stream()
            .map(this::toFormationRun)
            .toList();
    }
}
