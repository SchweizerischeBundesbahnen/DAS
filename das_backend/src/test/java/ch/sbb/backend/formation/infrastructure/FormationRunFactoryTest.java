package ch.sbb.backend.formation.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.formation.domain.model.FormationRun;
import ch.sbb.backend.formation.domain.model.TafTapLocationReference;
import ch.sbb.zis.trainformation.api.model.BrakeCalculationResult;
import ch.sbb.zis.trainformation.api.model.ConsolidatedBrakingInformation;
import ch.sbb.zis.trainformation.api.model.FormationRunInspection;
import ch.sbb.zis.trainformation.api.model.LocationUic;
import ch.sbb.zis.trainformation.api.model.MaxUphillDownhillGradients;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;

class FormationRunFactoryTest {

    @Test
    void create() {
        FormationRunInspection formationRunInspection = new FormationRunInspection();
        formationRunInspection.setInspected(true);
        BrakeCalculationResult brakeCalculationResult = new BrakeCalculationResult();
        brakeCalculationResult.setTractionLengthInCentimeter(320);
        brakeCalculationResult.setHauledLoadLengthInCentimeter(65);
        brakeCalculationResult.setTotalLengthInCentimeter(385);
        brakeCalculationResult.setTractionGrossWeightInTonne(45);
        brakeCalculationResult.setHauledLoadInTonne(56);
        brakeCalculationResult.setTractionBrakedWeightInTonne(34);
        brakeCalculationResult.setHauledLoadBrakedWeightInTonne(65);
        brakeCalculationResult.setBrakePositionGForLeadingTraction(false);
        brakeCalculationResult.setBrakePositionGForBrakeUnit1to5(true);
        brakeCalculationResult.setBrakePositionGForLoadHauled(false);
        formationRunInspection.setBrakeCalculationResult(brakeCalculationResult);

        ch.sbb.zis.trainformation.api.model.FormationRun formationRun = new ch.sbb.zis.trainformation.api.model.FormationRun();
        formationRun.setFormationRunInspection(formationRunInspection);
        formationRun.setStartLocationUic(new LocationUic(null, 34, 110));
        formationRun.setEndLocationUic(new LocationUic(null, 34, 78261));
        formationRun.setSmsEvu("2357");
        formationRun.setTrainSequence("TC");
        formationRun.setConsolidatedBrakingInformation(new ConsolidatedBrakingInformation(true, 34, 65, false, 45,
            new MaxUphillDownhillGradients(96, 67),
            "32.4", "RC", 12));

        FormationRun expectedFormationRun = FormationRun.builder()
            .inspected(true)
            .company("2357")
            .tafTapLocationReferenceStart(new TafTapLocationReference(34, 11))
            .tafTapLocationReferenceEnd(new TafTapLocationReference(34, 7826))
            .trainCategoryCode("TC")
            .brakedWeightPercentage(null)
            .tractionMaxSpeedInKmh(12)
            .hauledLoadMaxSpeedInKmh(65)
            .formationMaxSpeedInKmh(34)
            .tractionLengthInCm(320)
            .hauledLoadLengthInCm(65)
            .formationLengthInCm(385)
            .tractionGrossWeightInT(45)
            .hauledLoadGrossWeightInT(56)
            .tractionBrakedWeightInT(34)
            .hauledLoadBrakedWeightInT(65)
            .brakePositionGForLeadingTraction(false)
            .brakePositionGForBrakeUnit1to5(true)
            .brakePositionGForLoadHauled(false)
            .simTrain(false)
            .carCarrierVehicle(true)
            .axleLoadMaxInKg(45)
            .routeClass("RC")
            .gradientUphillMaxInPermille(67)
            .gradientDownhillMaxInPermille(96)
            .slopeMaxForHoldingForceMinInPermille("32.4")
            .vehicles(Collections.emptyList())
            .build();

        // Act
        List<FormationRun> result = FormationRunFactory.create(List.of(formationRun));

        // Assert
        assertThat(result).hasSize(1);
        FormationRun formationRunResult = result.getFirst();
        assertThat(formationRunResult).isEqualTo(expectedFormationRun);
    }
}
