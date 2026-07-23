package ch.sbb.das.backend.cargo.api.v1.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.Builder;

// todo: property descriptions
@Builder
@Schema(description = "Consolidated braking information of a formation run between two location references (implied by involved train wagons).")
@JsonInclude(JsonInclude.Include.NON_NULL)
public record FormationRun(
    @Schema(description = "Last modification date and time of the formation run.", requiredMode = Schema.RequiredMode.REQUIRED)
    OffsetDateTime inspectionDateTime,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    String tafTapLocationReferenceStart,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    String tafTapLocationReferenceEnd,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    String trainCategoryCode,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer brakedWeightPercentage,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer tractionMaxSpeedInKmh,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Integer hauledLoadMaxSpeedInKmh,
    @Schema(requiredMode = RequiredMode.REQUIRED)
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
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    Integer hauledLoadHoldingForceInHectoNewton,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer formationHoldingForceInHectoNewton,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean brakePositionGForLeadingTraction,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean brakePositionGForBrakeUnit1to5,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean brakePositionGForLoadHauled,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean simTrain,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    List<String> additionalTractions,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean carCarrierVehicle,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Boolean dangerousGoods,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesCount,
    // todo: delete as soon as das_client v 0.49.0 released
    @Deprecated(forRemoval = true)
    @Schema(requiredMode = RequiredMode.REQUIRED, deprecated = true)
    Integer vehiclesWithBrakeDesignLlAndKCount,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesWithBrakeDesignLAndLlAndKCount,
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
    @Schema(requiredMode = RequiredMode.REQUIRED)
    String routeClass,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer gradientUphillMaxInPermille,
    @Schema(requiredMode = RequiredMode.REQUIRED)
    Integer gradientDownhillMaxInPermille,
    @Schema(requiredMode = RequiredMode.NOT_REQUIRED)
    String slopeMaxForHoldingForceMinInPermille
) {

}
