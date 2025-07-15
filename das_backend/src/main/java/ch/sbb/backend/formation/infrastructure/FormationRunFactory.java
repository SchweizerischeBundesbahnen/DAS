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
        return new FormationRun(
            formationRun.getFormationRunInspection().getInspected(),
            formationRun.getSmsEvu(),
            mapToTafTapLocationReference(formationRun.getStartLocationUic()),
            mapToTafTapLocationReference(formationRun.getEndLocationUic()),
            formationRun.getTrainSequence(),
            formationRun.getBrakeSequence(),
            consolidatedBrakingInformation.getTractionMaxSpeedInKilometerPerHour(),
            consolidatedBrakingInformation.getHauledLoadMaxSpeedInKilometerPerHour(),
            brakeCalculationResult.getTractionLengthInCentimeter(),
            brakeCalculationResult.getHauledLoadLengthInCentimeter(),
            brakeCalculationResult.getTractionGrossWeightInTonne(),
            brakeCalculationResult.getHauledLoadInTonne(),
            brakeCalculationResult.getTractionBrakedWeightInTonne(),
            brakeCalculationResult.getHauledLoadBrakedWeightInTonne(),
            brakeCalculationResult.getBrakePositionGForLeadingTraction(),
            brakeCalculationResult.getBrakePositionGForBrakeUnit1to5(),
            brakeCalculationResult.getBrakePositionGForLoadHauled(),
            consolidatedBrakingInformation.getIsSimZug(),
            consolidatedBrakingInformation.getCarCarrierWagon(),
            consolidatedBrakingInformation.getMaxAxleLoadInKilogrammes(),
            consolidatedBrakingInformation.getRouteClass(),
            consolidatedBrakingInformation.getMaxUphillDownhillGradients().getMaxUphillGradientInPermille(),
            consolidatedBrakingInformation.getMaxUphillDownhillGradients().getMaxDownhillGradientInPermille(),
            consolidatedBrakingInformation.getMaximumSlopeForMinimumHoldingForceInPermille(),
            VehicleFactory.create(formationRun.getVehicleGroups()));
    }

    private static TafTapLocationReference mapToTafTapLocationReference(LocationUic locationUic) {
        return new TafTapLocationReference(locationUic.getCountryCodeUic(), locationUic.getUicCode());
    }
}
