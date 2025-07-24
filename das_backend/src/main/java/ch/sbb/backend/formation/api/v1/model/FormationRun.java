package ch.sbb.backend.formation.api.v1.model;

import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.Builder;

// todo: property descriptions
@Builder
public record FormationRun(
    @Schema(description = "Last modification date and time of the formation run.", requiredMode = Schema.RequiredMode.REQUIRED)
    OffsetDateTime modifiedDateTime,
    @Schema(description = "blabla", requiredMode = Schema.RequiredMode.REQUIRED)
    String tafTapLocationReferenceStart,
    @Schema(description = "blabla", requiredMode = Schema.RequiredMode.REQUIRED)
    String tafTapLocationReferenceEnd,
    //todo all requiredModes and default values
    // todo null values not transmitted on API (JSONIncluede false)
    String trainCategoryCode,
    Integer brakedWeightPercentage,
    Integer tractionMaxSpeedInKmh,
    Integer hauledLoadMaxSpeedInKmh,
    Integer formationMaxSpeedInKmh,
    Integer tractionLengthInCm,
    Integer hauledLoadLengthInCm,
    Integer formationLengthInCm,
    Integer tractionWeightInT,
    Integer hauledLoadWeightInT,
    Integer formationWeightInT,
    Integer tractionBrakedWeightInT,
    Integer hauledLoadBrakedWeightInT,
    Integer formationBrakedWeightInT,
    Integer tractionHoldingForceInHectoNewton,
    Integer hauledLoadHoldingForceInHectoNewton,
    Integer formationHoldingForceInHectoNewton,
    Boolean brakePositionGForLeadingTraction,
    Boolean brakePositionGForBrakeUnit1to5,
    Boolean brakePositionGForLoadHauled,
    Boolean simTrain,
    List<String> tractionModes,
    Boolean carCarrierVehicle,
    Boolean dangerousGoods,
    Integer vehiclesCount,
    Integer vehiclesWithBrakeDesignLlAndKCount,
    Integer vehiclesWithBrakeDesignDCount,
    Integer vehiclesWithDisabledBrakesCount,
    String europeanVehicleNumberFirst,
    String europeanVehicleNumberLast,
    Integer axleLoadMaxInKg,
    String routeClass,
    Integer gradientUphillMaxInPermille,
    Integer gradientDownhillMaxInPermille,
    String slopeMaxForHoldingForceMinInPermille
) {

    private static FormationRun from(TrainFormationRunEntity trainFormationRunEntity) {
        //      todo  consider use mapper (cause of testing effort)
        return FormationRun.builder()
            .modifiedDateTime(trainFormationRunEntity.getModifiedDateTime())
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
            .tractionWeightInT(trainFormationRunEntity.getTractionGrossWeightInT())
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
            .tractionModes(trainFormationRunEntity.getTractionModes())
            .carCarrierVehicle(trainFormationRunEntity.getCarCarrierVehicle())
            .dangerousGoods(trainFormationRunEntity.getDangerousGoods())
            .vehiclesCount(trainFormationRunEntity.getVehiclesCount())
            .vehiclesWithBrakeDesignLlAndKCount(trainFormationRunEntity.getVehiclesWithBrakeDesignLlAndKCount())
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

    static List<FormationRun> fromList(List<TrainFormationRunEntity> trainFormationRunEntities) {
        return trainFormationRunEntities.stream()
            .map(FormationRun::from)
            .toList();
    }
}
