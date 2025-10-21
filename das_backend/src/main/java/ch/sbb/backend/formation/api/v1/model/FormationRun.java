package ch.sbb.backend.formation.api.v1.model;

import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.Builder;

// todo: property descriptions
// todo: check required/non-required resp. default values with source
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public record FormationRun(
    @Schema(description = "Last modification date and time of the formation run.", requiredMode = Schema.RequiredMode.REQUIRED)
    OffsetDateTime inspectionDateTime,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    String tafTapLocationReferenceStart,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    String tafTapLocationReferenceEnd,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String trainCategoryCode,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Integer brakedWeightPercentage,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Integer tractionMaxSpeedInKmh,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Integer hauledLoadMaxSpeedInKmh,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Integer formationMaxSpeedInKmh,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer tractionLengthInCm,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer hauledLoadLengthInCm,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer formationLengthInCm,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer tractionWeightInT,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer hauledLoadWeightInT,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer formationWeightInT,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer tractionBrakedWeightInT,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer hauledLoadBrakedWeightInT,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer formationBrakedWeightInT,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer tractionHoldingForceInHectoNewton,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer hauledLoadHoldingForceInHectoNewton,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer formationHoldingForceInHectoNewton,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Boolean brakePositionGForLeadingTraction,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Boolean brakePositionGForBrakeUnit1to5,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Boolean brakePositionGForLoadHauled,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean simTrain,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String additionalTractionMode,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String additionalTractionSeries,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean carCarrierVehicle,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean dangerousGoods,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesCount,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesWithBrakeDesignLlAndKCount,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesWithBrakeDesignDCount,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesWithDisabledBrakesCount,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String europeanVehicleNumberFirst,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String europeanVehicleNumberLast,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer axleLoadMaxInKg,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String routeClass,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer gradientUphillMaxInPermille,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer gradientDownhillMaxInPermille,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String slopeMaxForHoldingForceMinInPermille
) {

    private static FormationRun from(TrainFormationRunEntity trainFormationRunEntity) {
        //      todo  consider use mapper (cause of testing effort)
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
            .additionalTractionMode(trainFormationRunEntity.getAdditionalTractionMode())
            .additionalTractionSeries(trainFormationRunEntity.getAdditionalTractionSeries())
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
