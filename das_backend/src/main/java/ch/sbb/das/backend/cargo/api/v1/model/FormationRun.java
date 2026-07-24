package ch.sbb.das.backend.cargo.api.v1.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.Builder;

@Builder
@Schema(description = "Consolidated braking information of a formation run between two location references (implied by involved train wagons).")
@JsonInclude(JsonInclude.Include.NON_NULL)
public record FormationRun(
    @Schema(description = "Timestamp of the last brake inspection / brake calculation for this formation run.", requiredMode = Schema.RequiredMode.REQUIRED)
    OffsetDateTime inspectionDateTime,

    @Schema(description = "TAF/TAP location reference of the starting location of this formation run.", requiredMode = Schema.RequiredMode.REQUIRED, example = "CH07000")
    String tafTapLocationReferenceStart,

    @Schema(description = "TAF/TAP location reference of the ending location of this formation run.", requiredMode = Schema.RequiredMode.REQUIRED, example = "CH07000")
    String tafTapLocationReferenceEnd,

    @Schema(description = "Train sequence (Zugreihe) of the formation run.", requiredMode = RequiredMode.REQUIRED, example = "R")
    String trainCategoryCode,

    @Schema(description = "Braked weight percentage (Bremsreihe) of the formation run.", requiredMode = RequiredMode.REQUIRED)
    Integer brakedWeightPercentage,

    @Schema(description = "Maximum permitted speed of the traction unit(s) alone, in km/h.", requiredMode = RequiredMode.REQUIRED)
    Integer tractionMaxSpeedInKmh,

    @Schema(description = "Maximum permitted speed of the hauled load (wagons) in km/h. Not set when the formation run has no hauled load.", requiredMode = RequiredMode.NOT_REQUIRED)
    Integer hauledLoadMaxSpeedInKmh,

    @Schema(description = "Maximum permitted speed of the entire formation in km/h, taking the traction, the hauled load into account.", requiredMode = RequiredMode.REQUIRED)
    Integer formationMaxSpeedInKmh,

    @Schema(description = "Total length of the traction unit(s) in centimeters.", requiredMode = RequiredMode.REQUIRED)
    Integer tractionLengthInCm,

    @Schema(description = "Total length of the hauled load (wagons) in centimeters. 0 if no hauled load is present.", requiredMode = RequiredMode.REQUIRED)
    Integer hauledLoadLengthInCm,

    @Schema(description = "Total length of the entire formation in centimeters.", requiredMode = RequiredMode.REQUIRED)
    Integer formationLengthInCm,

    @Schema(description = "Gross weight of the traction unit(s) in tons.", requiredMode = RequiredMode.REQUIRED)
    Integer tractionWeightInT,

    @Schema(description = "Gross weight of the hauled load (wagons) in tons. 0 if no hauled load is present.", requiredMode = RequiredMode.REQUIRED)
    Integer hauledLoadWeightInT,

    @Schema(description = "Gross weight of the entire formation in metric ton.", requiredMode = RequiredMode.REQUIRED)
    Integer formationWeightInT,

    @Schema(description = "Braked weight of the traction unit(s) in tons.", requiredMode = RequiredMode.REQUIRED)
    Integer tractionBrakedWeightInT,

    @Schema(description = "Braked weight of the hauled load in tons.", requiredMode = RequiredMode.REQUIRED)
    Integer hauledLoadBrakedWeightInT,

    @Schema(description = "Braked weight of the entire formation in tons.", requiredMode = RequiredMode.REQUIRED)
    Integer formationBrakedWeightInT,

    @Schema(description = "Holding force (Festhaltekraft) of the traction unit(s), in hectonewtons (hN).", requiredMode = RequiredMode.REQUIRED)
    Integer tractionHoldingForceInHectoNewton,

    @Schema(description = "Holding force (Festhaltekraft) of the hauled load in hectonewtons (hN).", requiredMode = RequiredMode.NOT_REQUIRED)
    Integer hauledLoadHoldingForceInHectoNewton,

    @Schema(description = "Total holding force (Festhaltekraft) of the entire formation, in hectonewtons (hN).", requiredMode = RequiredMode.REQUIRED)
    Integer formationHoldingForceInHectoNewton,

    @Schema(description = "True if the units in front of the traction unit's are calculated using brake weight G, if applicable.", requiredMode = RequiredMode.REQUIRED)
    Boolean brakePositionGForLeadingTraction,

    @Schema(description = "True if the vehicles behind the leading traction unit(s), within the first five braking units, are calculated using the braking weight G, if available.", requiredMode = RequiredMode.REQUIRED)
    Boolean brakePositionGForBrakeUnit1to5,

    @Schema(description = "True if the vehicles behind leading traction unit(s) are calculated using the braking weight G, if applicable.", requiredMode = RequiredMode.REQUIRED)
    Boolean brakePositionGForLoadHauled,

    @Schema(description = "True if this formation is a SIM train.", requiredMode = RequiredMode.REQUIRED)
    Boolean simTrain,

    @Schema(description = "Identifiers of additional traction units present in the formation besides the leading traction. Empty list if none.", requiredMode = RequiredMode.REQUIRED)
    List<String> additionalTractions,

    @Schema(description = "True if the formation contains at least one car carrier wagon (Doppelstock-Autotransportwagen).", requiredMode = RequiredMode.REQUIRED)
    Boolean carCarrierVehicle,

    @Schema(description = "True if the formation transports dangerous goods (RID) in any of its wagons.", requiredMode = RequiredMode.REQUIRED)
    Boolean dangerousGoods,

    @Schema(description = "Total number of vehicles (without traction unit(s)) in the formation.", requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesCount,

    // todo: delete as soon as das_client v 0.49.0 released
    @Deprecated(forRemoval = true)
    @Schema(description = "Deprecated: Use vehiclesWithBrakeDesignLAndLlAndKCount. Number of vehicles in the formation whose brake block design is L, LL or K.", requiredMode = RequiredMode.REQUIRED, deprecated = true)
    Integer vehiclesWithBrakeDesignLlAndKCount,

    @Schema(description = "Number of vehicles in the formation whose brake block design is L, LL or K.", requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesWithBrakeDesignLAndLlAndKCount,

    @Schema(description = "Number of vehicles in the formation whose brake design is D.", requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesWithBrakeDesignDCount,

    @Schema(description = "Number of vehicles in the formation whose brakes are disabled.", requiredMode = RequiredMode.REQUIRED)
    Integer vehiclesWithDisabledBrakesCount,

    @Schema(description = "European Vehicle Number (EVN) of the first vehicle of the hauled load. Not set when the formation run has no hauled load.", requiredMode = RequiredMode.NOT_REQUIRED)
    String europeanVehicleNumberFirst,

    @Schema(description = "European Vehicle Number (EVN) of the last vehicle of the hauled load. Not set when the formation run has no hauled load.", requiredMode = RequiredMode.NOT_REQUIRED)
    String europeanVehicleNumberLast,

    @Schema(description = "Maximum axle load of the hauled load, in kilograms.", requiredMode = RequiredMode.REQUIRED)
    Integer axleLoadMaxInKg,

    @Schema(description = "Maximum classification of route class (Streckenklasse).", requiredMode = RequiredMode.REQUIRED)
    String routeClass,

    @Schema(description = "Maximum uphill gradient the formation is permitted to run on a section, in per mille (‰).", requiredMode = RequiredMode.REQUIRED)
    Integer gradientUphillMaxInPermille,

    @Schema(description = "Maximum downhill gradient the formation is permitted to run on a section, in per mille (‰).", requiredMode = RequiredMode.REQUIRED)
    Integer gradientDownhillMaxInPermille,

    @Schema(description = "Maximum slope in per mille (‰) on which the formation's minimum available holding force is still sufficient to secure it against rolling away (Mindestfesthaltekraft).", requiredMode = RequiredMode.NOT_REQUIRED)
    String slopeMaxForHoldingForceMinInPermille
) {

}

