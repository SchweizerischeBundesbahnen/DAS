package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.domain.model.FormationRun;
import ch.sbb.backend.formation.domain.model.FormationRun.FormationRunBuilder;
import ch.sbb.backend.formation.domain.model.TafTapLocationReference;
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

    private static final int UIC_CHECKDIGIT_DIVISOR = 10;

    public static List<FormationRun> create(List<ch.sbb.zis.trainformation.api.model.FormationRun> formationRuns) {
        return formationRuns.stream()
            .map(FormationRunFactory::create).toList();
    }

    private static FormationRun create(ch.sbb.zis.trainformation.api.model.FormationRun formationRun) {
        FormationRunBuilder builder = FormationRun.builder()
            .company(formationRun.getSmsEvu())
            .tafTapLocationReferenceStart(toTafTapLocationReference(formationRun.getStartLocationUic()))
            .tafTapLocationReferenceEnd(toTafTapLocationReference(formationRun.getEndLocationUic()))
            .trainCategoryCode(formationRun.getTrainSequence())
            .brakedWeightPercentage(formationRun.getBrakeSequence())
            .vehicles(VehicleFactory.create(formationRun.getVehicleGroups()));
        applyConsolidatedBrakingInformation(builder, formationRun.getConsolidatedBrakingInformation());
        applyFormationRunInspection(builder, formationRun.getFormationRunInspection());
        return builder.build();
    }

    private static TafTapLocationReference toTafTapLocationReference(LocationUic locationUic) {
        int uicCodeWithoutCheckdigit = locationUic.getUicCode() / UIC_CHECKDIGIT_DIVISOR;
        String countryCodeIso = TafTapLocationReference.toCountryCodeIso(locationUic.getCountryCodeUic());
        return new TafTapLocationReference(countryCodeIso, uicCodeWithoutCheckdigit);
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
