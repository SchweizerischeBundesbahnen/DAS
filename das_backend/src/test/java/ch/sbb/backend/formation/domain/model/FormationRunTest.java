package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;

import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

class FormationRunTest {

    @Test
    void constructor_getters() {
        TafTapLocationReference start = new TafTapLocationReference("CH", 1);
        TafTapLocationReference end = new TafTapLocationReference("CH", 2);

        FormationRun result = FormationRun.builder()
            .company("1134")
            .tafTapLocationReferenceStart(start)
            .tafTapLocationReferenceEnd(end)
            .trainCategoryCode("TC")
            .brakedWeightPercentage(23)
            .tractionMaxSpeedInKmh(120)
            .hauledLoadMaxSpeedInKmh(110)
            .formationMaxSpeedInKmh(110)
            .tractionLengthInCm(12000)
            .hauledLoadLengthInCm(8000)
            .formationLengthInCm(20000)
            .tractionGrossWeightInT(50)
            .hauledLoadGrossWeightInT(100)
            .tractionBrakedWeightInT(85)
            .hauledLoadBrakedWeightInT(4)
            .brakePositionGForLeadingTraction(true)
            .brakePositionGForBrakeUnit1to5(false)
            .brakePositionGForLoadHauled(true)
            .simTrain(true)
            .carCarrierVehicle(false)
            .axleLoadMaxInKg(10000)
            .routeClass("RC")
            .gradientUphillMaxInPermille(50)
            .gradientDownhillMaxInPermille(30)
            .slopeMaxForHoldingForceMinInPermille("5.6")
            .build();

        assertThat(result.getCompany()).isEqualTo("1134");
        assertThat(result.getTafTapLocationReferenceStart()).isEqualTo(start);
        assertThat(result.getTafTapLocationReferenceEnd()).isEqualTo(end);
        assertThat(result.getTrainCategoryCode()).isEqualTo("TC");
        assertThat(result.getBrakedWeightPercentage()).isEqualTo(23);
        assertThat(result.getTractionMaxSpeedInKmh()).isEqualTo(120);
        assertThat(result.getHauledLoadMaxSpeedInKmh()).isEqualTo(110);
        assertThat(result.getFormationMaxSpeedInKmh()).isEqualTo(110);
        assertThat(result.getTractionLengthInCm()).isEqualTo(12000);
        assertThat(result.getHauledLoadLengthInCm()).isEqualTo(8000);
        assertThat(result.getFormationLengthInCm()).isEqualTo(20000);
        assertThat(result.getTractionGrossWeightInT()).isEqualTo(50);
        assertThat(result.getHauledLoadGrossWeightInT()).isEqualTo(100);
        assertThat(result.getTractionBrakedWeightInT()).isEqualTo(85);
        assertThat(result.getHauledLoadBrakedWeightInT()).isEqualTo(4);
        assertThat(result.getBrakePositionGForLeadingTraction()).isTrue();
        assertThat(result.getBrakePositionGForBrakeUnit1to5()).isFalse();
        assertThat(result.getBrakePositionGForLoadHauled()).isTrue();
        assertThat(result.getSimTrain()).isTrue();
        assertThat(result.getCarCarrierVehicle()).isFalse();
        assertThat(result.getAxleLoadMaxInKg()).isEqualTo(10000);
        assertThat(result.getRouteClass()).isEqualTo("RC");
        assertThat(result.getGradientUphillMaxInPermille()).isEqualTo(50);
        assertThat(result.getGradientDownhillMaxInPermille()).isEqualTo(30);
        assertThat(result.getSlopeMaxForHoldingForceMinInPermille()).isEqualTo("5.6");
    }

    @Test
    void isInspected_withNull() {
        List<FormationRun> result = FormationRun.filterValid(null);
        assertThat(result).isEmpty();
    }

    @Test
    void isInspected_withEmpty() {
        List<FormationRun> result = FormationRun.filterValid(Collections.emptyList());
        assertThat(result).isEmpty();
    }

    @Test
    void inspected_withIsInspectedAndUninspected() {
        FormationRun inspected1 = createFormationRun(true, "3012");
        FormationRun inspected2 = createFormationRun(true, "1023");
        List<FormationRun> formationRuns = List.of(createFormationRun(false, "5443"), inspected1, inspected2);

        List<FormationRun> result = FormationRun.filterValid(formationRuns);

        assertThat(result).hasSize(2)
            .contains(inspected1)
            .contains(inspected2);
    }

    @Test
    void isInspected_withUnknownCompany() {
        List<FormationRun> formationRuns = List.of(createFormationRun(true, "0000"), createFormationRun(true, null));

        List<FormationRun> result = FormationRun.filterValid(formationRuns);

        assertThat(result).isEmpty();
    }

    @Test
    void getFormationGrossWeightInT_correct() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionGrossWeightInT(53)
            .hauledLoadGrossWeightInT(102)
            .build();

        int result = formationRun.getFormationGrossWeightInT();

        assertThat(result).isEqualTo(155);
    }

    @Test
    void getFormationGrossWeightInT_null() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionGrossWeightInT(null)
            .hauledLoadGrossWeightInT(null)
            .build();

        Integer result = formationRun.getFormationGrossWeightInT();

        assertThat(result).isNull();
    }

    @Test
    void getFormationBrakedWeightInT_correct() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionBrakedWeightInT(87)
            .hauledLoadBrakedWeightInT(4)
            .build();

        int result = formationRun.getFormationBrakedWeightInT();

        assertThat(result).isEqualTo(91);
    }

    @Test
    void getFormationBrakedWeightInT_null() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionBrakedWeightInT(null)
            .hauledLoadBrakedWeightInT(null)
            .build();

        Integer result = formationRun.getFormationBrakedWeightInT();

        assertThat(result).isNull();
    }

    @Test
    void getTractionHoldingForceInHectoNewton_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(Collections.emptyList());

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.calculateTractionHoldingForceInHectoNewton(any())).thenReturn(59);

            int result = formationRun.getTractionHoldingForceInHectoNewton();

            assertThat(result).isEqualTo(59);
        }
    }

    @Test
    void getHauledLoadHoldingForceInHectoNewton_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(Collections.emptyList());

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.calculateHauledLoadHoldingForceInHectoNewton(any())).thenReturn(67);

            int result = formationRun.getHauledLoadHoldingForceInHectoNewton();

            assertThat(result).isEqualTo(67);
        }
    }

    @Test
    void getFormationHoldingForceInHectoNewton_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(Collections.emptyList());

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.calculateHoldingForce(any())).thenReturn(3);

            int result = formationRun.getFormationHoldingForceInHectoNewton();

            assertThat(result).isEqualTo(3);
        }
    }

    @Test
    void getTractionModes_empty() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.tractionModes(any())).thenReturn(Collections.emptyList());
            List<TractionMode> tractionModes = formationRun.getTractionModes();
            assertThat(tractionModes).isEmpty();
        }
    }

    @Test
    void getTractionModes_withTractionModes() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.tractionModes(any())).thenReturn(List.of(TractionMode.ZUGLOK, TractionMode.SCHIEBELOK, TractionMode.DOPPELTRAKTION));
            List<TractionMode> tractionModes = formationRun.getTractionModes();
            assertThat(tractionModes).isEqualTo(List.of(TractionMode.ZUGLOK, TractionMode.SCHIEBELOK, TractionMode.DOPPELTRAKTION));
        }
    }

    @Test
    void hasDangerousGoods_withDangerousGoods() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.hasDangerousGoods(any())).thenReturn(true);

            boolean result = formationRun.hasDangerousGoods();

            assertThat(result).isTrue();
        }
    }

    @Test
    void vehiclesCount_twoHauledLoadVehicles() {
        FormationRun formationRun = createFormationRunWithVehicles(List.of(mock(Vehicle.class), mock(Vehicle.class)));

        Integer result = formationRun.hauledLoadVehiclesCount();

        assertThat(result).isEqualTo(2);
    }

    @Test
    void vehiclesWithBrakeDesignCount_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.countBrakeDesigns(any(), any(), any())).thenReturn(3);

            Integer result = formationRun.vehiclesWithBrakeDesignCount(BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE, BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE);

            mockedStatic.verify(() -> Vehicle.countBrakeDesigns(any(), eq(BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE), eq(BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE)));
            assertThat(result).isEqualTo(3);
        }
    }

    @Test
    void vehiclesWithDisabledBrakeCount_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.countDisabledBrakes(any())).thenReturn(5);

            Integer result = formationRun.vehiclesWithDisabledBrakeCount();

            assertThat(result).isEqualTo(5);
        }
    }

    @Test
    void europeanVehicleNumbers_null() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.europeanVehicleNumberFirst(any())).thenReturn(null);

            assertThat(formationRun.europeanVehicleNumberFirst()).isNull();
            assertThat(formationRun.europeanVehicleNumberLast()).isNull();
        }
    }

    @Test
    void europeanVehicleNumberFirst_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.europeanVehicleNumberFirst(any())).thenReturn("951234564");

            String result = formationRun.europeanVehicleNumberFirst();

            assertThat(result).isEqualTo("951234564");
        }
    }

    @Test
    void europeanVehicleNumberLast_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.europeanVehicleNumberLast(any())).thenReturn("12789107");

            String result = formationRun.europeanVehicleNumberLast();

            assertThat(result).isEqualTo("12789107");
        }
    }

    private FormationRun createFormationRun(Boolean inspected, String company) {
        return FormationRun.builder()
            .inspected(inspected)
            .company(company)
            .build();
    }

    private FormationRun createFormationRunWithVehicles(List<Vehicle> vehicles) {
        return FormationRun.builder()
            .inspected(true)
            .vehicles(vehicles)
            .build();
    }
}