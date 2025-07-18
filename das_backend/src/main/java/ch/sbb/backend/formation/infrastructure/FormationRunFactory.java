package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.domain.model.FormationRun;
import ch.sbb.backend.formation.domain.model.TafTapLocationReference;
import ch.sbb.zis.trainformation.api.model.BrakeCalculationResult;
import ch.sbb.zis.trainformation.api.model.ConsolidatedBrakingInformation;
import ch.sbb.zis.trainformation.api.model.LocationUic;
import java.util.List;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public final class FormationRunFactory {

    public static List<FormationRun> create(List<ch.sbb.zis.trainformation.api.model.FormationRun> formationRuns) {
        return formationRuns.stream()
            .filter(formationRun -> formationRun.getFormationRunInspection().getInspected())
            .map(FormationRunFactory::create).toList();
    }

    private static FormationRun create(ch.sbb.zis.trainformation.api.model.FormationRun formationRun) {
        ConsolidatedBrakingInformation consolidatedBrakingInformation = formationRun.getConsolidatedBrakingInformation();
        BrakeCalculationResult brakeCalculationResult = formationRun.getFormationRunInspection().getBrakeCalculationResult();
        return FormationRun.builder()
            .inspected(formationRun.getFormationRunInspection().getInspected())
            .company(formationRun.getSmsEvu())
            .tafTapLocationReferenceStart(mapToTafTapLocationReference(formationRun.getStartLocationUic()))
            .tafTapLocationReferenceEnd(mapToTafTapLocationReference(formationRun.getEndLocationUic()))
            .trainCategoryCode(formationRun.getTrainSequence())
            .brakedWeightPercentage(formationRun.getBrakeSequence())
            .tractionMaxSpeedInKmh(consolidatedBrakingInformation.getTractionMaxSpeedInKilometerPerHour())
            .hauledLoadMaxSpeedInKmh(consolidatedBrakingInformation.getHauledLoadMaxSpeedInKilometerPerHour())
            .formationMaxSpeedInKmh(consolidatedBrakingInformation.getFormationMaxSpeedInKilometerPerHour())
            .tractionLengthInCm(brakeCalculationResult.getTractionLengthInCentimeter())
            .hauledLoadLengthInCm(brakeCalculationResult.getHauledLoadLengthInCentimeter())
            .formationLengthInCm(brakeCalculationResult.getTotalLengthInCentimeter())
            .tractionGrossWeightInT(brakeCalculationResult.getTractionGrossWeightInTonne())
            .hauledLoadGrossWeightInT(brakeCalculationResult.getHauledLoadInTonne())
            .tractionBrakedWeightInT(brakeCalculationResult.getTractionBrakedWeightInTonne())
            .hauledLoadBrakedWeightInT(brakeCalculationResult.getHauledLoadBrakedWeightInTonne())
            .brakePositionGForLeadingTraction(brakeCalculationResult.getBrakePositionGForLeadingTraction())
            .brakePositionGForBrakeUnit1to5(brakeCalculationResult.getBrakePositionGForBrakeUnit1to5())
            .brakePositionGForLoadHauled(brakeCalculationResult.getBrakePositionGForLoadHauled())
            .simTrain(consolidatedBrakingInformation.getIsSimZug())
            .carCarrierVehicle(consolidatedBrakingInformation.getCarCarrierWagon())
            .axleLoadMaxInKg(consolidatedBrakingInformation.getMaxAxleLoadInKilogrammes())
            .routeClass(consolidatedBrakingInformation.getRouteClass())
            .gradientUphillMaxInPermille(consolidatedBrakingInformation.getMaxUphillDownhillGradients().getMaxUphillGradientInPermille())
            .gradientDownhillMaxInPermille(consolidatedBrakingInformation.getMaxUphillDownhillGradients().getMaxDownhillGradientInPermille())
            .slopeMaxForHoldingForceMinInPermille(consolidatedBrakingInformation.getMaximumSlopeForMinimumHoldingForceInPermille())
            .vehicles(VehicleFactory.create(formationRun.getVehicleGroups()))
            .build();
    }

    private static TafTapLocationReference mapToTafTapLocationReference(LocationUic locationUic) {
        return new TafTapLocationReference(locationUic.getCountryCodeUic(), locationUic.getUicCode());
    }
}
