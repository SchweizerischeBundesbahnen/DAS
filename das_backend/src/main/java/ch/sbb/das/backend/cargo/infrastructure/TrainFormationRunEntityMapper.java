package ch.sbb.das.backend.cargo.infrastructure;

import ch.sbb.das.backend.cargo.domain.model.BrakeDesign;
import ch.sbb.das.backend.cargo.domain.model.Formation;
import ch.sbb.das.backend.cargo.domain.model.FormationRun;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.stereotype.Component;

@Component
public class TrainFormationRunEntityMapper {

    private static void applyFormationRun(TrainFormationRunEntity.TrainFormationRunEntityBuilder builder, FormationRun formationRun, AtomicInteger position) {
        builder
            .position(position.getAndIncrement())
            .inspectionDateTime(formationRun.getInspectionDateTime())
            .company(formationRun.getCompany())
            .tafTapLocationReferenceStart(formationRun.getTafTapLocationReferenceStart().toLocationCode())
            .tafTapLocationReferenceEnd(formationRun.getTafTapLocationReferenceEnd().toLocationCode())
            .trainCategoryCode(formationRun.getTrainCategoryCode())
            .brakedWeightPercentage(formationRun.getBrakedWeightPercentage())
            .tractionMaxSpeedInKmh(formationRun.getTractionMaxSpeedInKmh())
            .hauledLoadMaxSpeedInKmh(formationRun.getHauledLoadMaxSpeedInKmh())
            .formationMaxSpeedInKmh(formationRun.getFormationMaxSpeedInKmh())
            .tractionLengthInCm(formationRun.getTractionLengthInCm())
            .hauledLoadLengthInCm(formationRun.getHauledLoadLengthInCm())
            .formationLengthInCm(formationRun.getFormationLengthInCm())
            .tractionWeightInT(formationRun.getTractionGrossWeightInT())
            .hauledLoadWeightInT(formationRun.getHauledLoadGrossWeightInT())
            .formationWeightInT(formationRun.getFormationGrossWeightInT())
            .tractionBrakedWeightInT(formationRun.getTractionBrakedWeightInT())
            .hauledLoadBrakedWeightInT(formationRun.getHauledLoadBrakedWeightInT())
            .formationBrakedWeightInT(formationRun.getFormationBrakedWeightInT())
            .tractionHoldingForceInHectoNewton(formationRun.getTractionHoldingForceInHectoNewton())
            .hauledLoadHoldingForceInHectoNewton(formationRun.getHauledLoadHoldingForceInHectoNewton())
            .formationHoldingForceInHectoNewton(formationRun.getFormationHoldingForceInHectoNewton())
            .brakePositionGForLeadingTraction(formationRun.getBrakePositionGForLeadingTraction())
            .brakePositionGForBrakeUnit1to5(formationRun.getBrakePositionGForBrakeUnit1to5())
            .brakePositionGForLoadHauled(formationRun.getBrakePositionGForLoadHauled())
            .simTrain(formationRun.getSimTrain())
            .additionalTractions(formationRun.getAdditionalTractions())
            .carCarrierVehicle(formationRun.getCarCarrierVehicle())
            .dangerousGoods(formationRun.hasDangerousGoods())
            .vehiclesCount(formationRun.hauledLoadVehiclesCount())
            .vehiclesWithBrakeDesignLAndLlAndKCount(
                formationRun.vehiclesWithBrakeDesignCount(BrakeDesign.L_KUNSTSTOFF_LEISE, BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE, BrakeDesign.KUNSTSTOFF_BREMSKLOETZE,
                    BrakeDesign.EINLOESIGE_BREMSE_MIT_KUNSTSTOFF_BREMSKLOETZEN))
            .vehiclesWithBrakeDesignDCount(formationRun.vehiclesWithBrakeDesignCount(BrakeDesign.SCHEIBENBREMSEN))
            .vehiclesWithDisabledBrakesCount(formationRun.vehiclesWithDisabledBrakeCount())
            .europeanVehicleNumberFirst(formationRun.getEuropeanVehicleNumberFirst())
            .europeanVehicleNumberLast(formationRun.getEuropeanVehicleNumberLast())
            .axleLoadMaxInKg(formationRun.getAxleLoadMaxInKg())
            .routeClass(formationRun.getRouteClass())
            .gradientUphillMaxInPermille(formationRun.getGradientUphillMaxInPermille())
            .gradientDownhillMaxInPermille(formationRun.getGradientDownhillMaxInPermille())
            .slopeMaxForHoldingForceMinInPermille(formationRun.getSlopeMaxForHoldingForceMinInPermille());
    }

    public List<TrainFormationRunEntity> toEntities(Formation formation) {
        AtomicInteger position = new AtomicInteger(0);
        return formation.validFormationRuns().stream()
            .map(formationRun -> {
                TrainFormationRunEntity.TrainFormationRunEntityBuilder builder = TrainFormationRunEntity.builder();
                applyFormationRun(builder, formationRun, position);
                builder
                    .operationalTrainNumber(formation.getOperationalTrainNumber())
                    .trainPathId(formation.getTrainPathId())
                    .operationalDay(formation.getOperationalDay());
                return builder.build();
            })
            .toList();
    }
}
