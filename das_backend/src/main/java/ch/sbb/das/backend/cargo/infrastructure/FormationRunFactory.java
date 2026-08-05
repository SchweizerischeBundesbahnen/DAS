package ch.sbb.das.backend.cargo.infrastructure;

import ch.sbb.das.backend.cargo.domain.model.FormationRun;
import ch.sbb.das.backend.cargo.domain.model.FormationRun.FormationRunBuilder;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import ch.sbb.zis.trainformation.api.model.BrakeCalculationResult;
import ch.sbb.zis.trainformation.api.model.ConsolidatedBrakingInformation;
import ch.sbb.zis.trainformation.api.model.FormationRunInspection;
import ch.sbb.zis.trainformation.api.model.LocationUic;
import ch.sbb.zis.trainformation.api.model.MaxUphillDownhillGradients;
import java.util.List;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public final class FormationRunFactory {

    public static List<FormationRun> create(List<ch.sbb.zis.trainformation.api.model.FormationRun> formationRuns) {
        return formationRuns.stream()
            .filter(formationRun -> CompanyCode.isValid(formationRun.getSmsEvu()))
            .map(FormationRunFactory::create)
            .toList();
    }

    private static FormationRun create(ch.sbb.zis.trainformation.api.model.FormationRun formationRun) {
        FormationRunBuilder builder = FormationRun.builder()
            .company(new CompanyCode(formationRun.getSmsEvu()))
            .tafTapLocationUicStartCode(toUicCode(formationRun.getStartLocationUic()))
            .tafTapLocationUicStartPassIndex(formationRun.getStartLocationUic() != null ? formationRun.getStartLocationUic().getBpZusatzId() : null)
            .tafTapLocationUicEndCode(toUicCode(formationRun.getEndLocationUic()))
            .trainCategoryCode(formationRun.getTrainSequence())
            .brakedWeightPercentage(formationRun.getBrakeSequence())
            .vehicles(VehicleFactory.create(formationRun.getVehicleGroups()));
        applyConsolidatedBrakingInformation(builder, formationRun.getConsolidatedBrakingInformation());
        applyFormationRunInspection(builder, formationRun.getFormationRunInspection());
        return builder.build();
    }

    private static Integer toUicCode(LocationUic locationUic) {
        if (locationUic == null) {
            return null;
        }
        return TafTapLocationReference.of(locationUic.getCountryCodeUic(), locationUic.getUicCode()).uicCode();
    }

    private static void applyFormationRunInspection(FormationRunBuilder builder, FormationRunInspection formationRunInspection) {
        if (formationRunInspection == null) {
            return;
        }
        builder.inspected(formationRunInspection.getInspected());
        builder.inspectionDateTime(formationRunInspection.getInspectionTime());
        applyBrakeCalculationResult(builder, formationRunInspection.getBrakeCalculationResult());
    }

    private static void applyBrakeCalculationResult(FormationRunBuilder builder, BrakeCalculationResult brakeCalculationResult) {
        if (brakeCalculationResult == null) {
            return;
        }
        builder
            .tractionLengthInCm(brakeCalculationResult.getTractionLengthInCentimeter())
            .hauledLoadLengthInCm(brakeCalculationResult.getHauledLoadLengthInCentimeter())
            .formationLengthInCm(brakeCalculationResult.getTotalLengthInCentimeter())
            .tractionGrossWeightInT(brakeCalculationResult.getTractionGrossWeightInTonne())
            .hauledLoadGrossWeightInT(brakeCalculationResult.getHauledLoadInTonne())
            .tractionBrakedWeightInT(brakeCalculationResult.getTractionBrakedWeightInTonne())
            .hauledLoadBrakedWeightInT(brakeCalculationResult.getHauledLoadBrakedWeightInTonne())
            .brakePositionGForLeadingTraction(brakeCalculationResult.getBrakePositionGForLeadingTraction())
            .brakePositionGForBrakeUnit1to5(brakeCalculationResult.getBrakePositionGForBrakeUnit1to5())
            .brakePositionGForLoadHauled(brakeCalculationResult.getBrakePositionGForLoadHauled());
    }

    private static void applyConsolidatedBrakingInformation(FormationRunBuilder builder, ConsolidatedBrakingInformation consolidatedBrakingInformation) {
        if (consolidatedBrakingInformation == null) {
            return;
        }
        builder
            .tractionMaxSpeedInKmh(consolidatedBrakingInformation.getTractionMaxSpeedInKilometerPerHour())
            .hauledLoadMaxSpeedInKmh(consolidatedBrakingInformation.getHauledLoadMaxSpeedInKilometerPerHour())
            .formationMaxSpeedInKmh(consolidatedBrakingInformation.getFormationMaxSpeedInKilometerPerHour())
            .simTrain(consolidatedBrakingInformation.getIsSimZug())
            .carCarrierVehicle(consolidatedBrakingInformation.getCarCarrierWagon())
            .axleLoadMaxInKg(consolidatedBrakingInformation.getMaxAxleLoadInKilogrammes())
            .routeClass(consolidatedBrakingInformation.getRouteClass())
            .slopeMaxForHoldingForceMinInPermille(consolidatedBrakingInformation.getMaximumSlopeForMinimumHoldingForceInPermille());
        applyMaxUphillDownhillGradients(builder, consolidatedBrakingInformation.getMaxUphillDownhillGradients());
    }

    private static void applyMaxUphillDownhillGradients(FormationRunBuilder builder, MaxUphillDownhillGradients maxUphillDownhillGradients) {
        if (maxUphillDownhillGradients == null) {
            return;
        }
        builder
            .gradientUphillMaxInPermille(maxUphillDownhillGradients.getMaxUphillGradientInPermille())
            .gradientDownhillMaxInPermille(maxUphillDownhillGradients.getMaxDownhillGradientInPermille());

    }
}
