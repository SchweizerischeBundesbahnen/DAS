package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.when;

import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

class FormationRunTest {

    @Test
    void constructor_getters() {
        TafTapLocationReference start = new TafTapLocationReference(34, 1);
        TafTapLocationReference end = new TafTapLocationReference(34, 2);

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

        assertEquals("1134", result.getCompany());
        assertEquals(start, result.getTafTapLocationReferenceStart());
        assertEquals(end, result.getTafTapLocationReferenceEnd());
        assertEquals("TC", result.getTrainCategoryCode());
        assertEquals(23, result.getBrakedWeightPercentage());
        assertEquals(120, result.getTractionMaxSpeedInKmh());
        assertEquals(110, result.getHauledLoadMaxSpeedInKmh());
        assertEquals(110, result.getFormationMaxSpeedInKmh());
        assertEquals(12000, result.getTractionLengthInCm());
        assertEquals(8000, result.getHauledLoadLengthInCm());
        assertEquals(20000, result.getFormationLengthInCm());
        assertEquals(50, result.getTractionGrossWeightInT());
        assertEquals(100, result.getHauledLoadGrossWeightInT());
        assertEquals(85, result.getTractionBrakedWeightInT());
        assertEquals(4, result.getHauledLoadBrakedWeightInT());
        assertTrue(result.getBrakePositionGForLeadingTraction());
        assertFalse(result.getBrakePositionGForBrakeUnit1to5());
        assertTrue(result.getBrakePositionGForLoadHauled());
        assertTrue(result.getSimTrain());
        assertFalse(result.getCarCarrierVehicle());
        assertEquals(10000, result.getAxleLoadMaxInKg());
        assertEquals("RC", result.getRouteClass());
        assertEquals(50, result.getGradientUphillMaxInPermille());
        assertEquals(30, result.getGradientDownhillMaxInPermille());
        assertEquals("5.6", result.getSlopeMaxForHoldingForceMinInPermille());
    }

    @Test
    void inspected_withNull() {
        List<FormationRun> result = FormationRun.valid(null);
        assertEquals(0, result.size());
    }

    @Test
    void inspected_withEmpty() {
        List<FormationRun> result = FormationRun.valid(Collections.emptyList());
        assertEquals(0, result.size());
    }

    @Test
    void inspected_withInspectedAndUninspected() {
        FormationRun inspected1 = createFormationRun(true, "3012");
        FormationRun inspected2 = createFormationRun(true, "1023");
        List<FormationRun> formationRuns = List.of(createFormationRun(false, "5443"), inspected1, inspected2);

        List<FormationRun> result = FormationRun.valid(formationRuns);

        assertEquals(2, result.size());
        assertTrue(result.contains(inspected1));
        assertTrue(result.contains(inspected2));
    }

    @Test
    void inspected_withInvalidCompany() {
        List<FormationRun> formationRuns = List.of(createFormationRun(true, "0000"), createFormationRun(true, null));

        List<FormationRun> result = FormationRun.valid(formationRuns);

        assertEquals(0, result.size());
    }

    @Test
    void formationGrossWeightInT_correct() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionGrossWeightInT(53)
            .hauledLoadGrossWeightInT(102)
            .build();

        int result = formationRun.formationGrossWeightInT();

        assertEquals(155, result);
    }

    @Test
    void formationGrossWeightInT_null() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionGrossWeightInT(null)
            .hauledLoadGrossWeightInT(null)
            .build();

        Integer result = formationRun.formationGrossWeightInT();

        assertNull(result);
    }

    @Test
    void formationBrakedWeightInT_correct() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionBrakedWeightInT(87)
            .hauledLoadBrakedWeightInT(4)
            .build();

        int result = formationRun.formationBrakedWeightInT();

        assertEquals(91, result);
    }

    @Test
    void formationBrakedWeightInT_null() {
        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .tractionBrakedWeightInT(null)
            .hauledLoadBrakedWeightInT(null)
            .build();

        Integer result = formationRun.formationBrakedWeightInT();

        assertNull(result);
    }

    @Test
    void tractionHoldingForceInHectoNewton_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(Collections.emptyList());

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.tractionHoldingForceInHectoNewton(any())).thenReturn(59);

            int result = formationRun.tractionHoldingForceInHectoNewton();

            assertEquals(59, result);
        }
    }

    @Test
    void hauledLoadHoldingForceInHectoNewton_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(Collections.emptyList());

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.hauledLoadHoldingForceInHectoNewton(any())).thenReturn(67);

            int result = formationRun.hauledLoadHoldingForceInHectoNewton();

            assertEquals(67, result);
        }
    }

    @Test
    void formationHoldingForceInHectoNewton_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(Collections.emptyList());

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.holdingForce(any())).thenReturn(3);

            int result = formationRun.formationHoldingForceInHectoNewton();

            assertEquals(3, result);
        }
    }

    @Test
    void tractionModes_null() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        List<TractionMode> tractionModes = formationRun.tractionModes();
        assertEquals(0, tractionModes.size());
    }

    @Test
    void tractionModes_empty() {
        FormationRun formationRun = createFormationRunWithVehicles(Collections.emptyList());
        List<TractionMode> tractionModes = formationRun.tractionModes();
        assertEquals(0, tractionModes.size());
    }

    @Test
    void tractionModes_noTractionVehicle() {
        Vehicle vehicle = mock(Vehicle.class);
        when(vehicle.isTraction()).thenReturn(false);
        when(vehicle.getTractionMode()).thenReturn(TractionMode.DOPPELTRAKTION);

        FormationRun formationRun = createFormationRunWithVehicles(List.of(vehicle));
        List<TractionMode> tractionModes = formationRun.tractionModes();
        assertEquals(0, tractionModes.size());
    }

    @Test
    void tractionModes_correct() {
        Vehicle vehicle1 = mock(Vehicle.class);
        when(vehicle1.isTraction()).thenReturn(true);
        when(vehicle1.getTractionMode()).thenReturn(TractionMode.DOPPELTRAKTION);
        Vehicle vehicle2 = mock(Vehicle.class);
        when(vehicle2.isTraction()).thenReturn(false);
        Vehicle vehicle3 = mock(Vehicle.class);
        when(vehicle3.isTraction()).thenReturn(true);
        when(vehicle3.getTractionMode()).thenReturn(TractionMode.SCHIEBELOK);

        FormationRun formationRun = createFormationRunWithVehicles(List.of(vehicle1, vehicle2, vehicle3));
        List<TractionMode> tractionModes = formationRun.tractionModes();
        assertEquals(2, tractionModes.size());
        assertEquals(TractionMode.DOPPELTRAKTION, tractionModes.get(0));
        assertEquals(TractionMode.SCHIEBELOK, tractionModes.get(1));
    }

    @Test
    void hasDangerousGoods_withDangerousGoods() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.hasDangerousGoods(any())).thenReturn(true);

            boolean result = formationRun.hasDangerousGoods();

            assertTrue(result);
        }
    }

    @Test
    void vehicleCount_null() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        Integer result = formationRun.vehicleCount();

        assertEquals(0, result);
    }

    @Test
    void vehicleCount_twoVehicles() {
        FormationRun formationRun = createFormationRunWithVehicles(List.of(mock(Vehicle.class), mock(Vehicle.class)));

        Integer result = formationRun.vehicleCount();

        assertEquals(2, result);
    }

    @Test
    void vehiclesWithBrakeDesignCount_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.brakeDesignCount(any(), any(), any())).thenReturn(3);

            Integer result = formationRun.vehiclesWithBrakeDesignCount(BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE, BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE);

            mockedStatic.verify(() -> Vehicle.brakeDesignCount(any(), eq(BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE), eq(BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE)));
            assertEquals(3, result);
        }
    }

    @Test
    void vehiclesWithDisabledBrakeCount_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);

        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.disabledBrakeCount(any())).thenReturn(5);

            Integer result = formationRun.vehiclesWithDisabledBrakeCount();

            assertEquals(5, result);
        }
    }

    @Test
    void europeanVehicleNumberFirst_null() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.first(any())).thenReturn(null);

            EuropeanVehicleNumber result = formationRun.europeanVehicleNumberFirst();

            assertNull(result);
        }
    }

    @Test
    void europeanVehicleNumberFirst_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            Vehicle vehicle = mock(Vehicle.class);
            EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber("12", "3456");
            when(vehicle.getEuropeanVehicleNumber()).thenReturn(europeanVehicleNumber);
            mockedStatic.when(() -> Vehicle.first(any())).thenReturn(vehicle);

            EuropeanVehicleNumber result = formationRun.europeanVehicleNumberFirst();

            assertEquals(europeanVehicleNumber, result);
        }
    }

    @Test
    void europeanVehicleNumberLast_null() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            mockedStatic.when(() -> Vehicle.last(any())).thenReturn(null);

            EuropeanVehicleNumber result = formationRun.europeanVehicleNumberLast();

            assertNull(result);
        }
    }

    @Test
    void europeanVehicleNumberLast_correct() {
        FormationRun formationRun = createFormationRunWithVehicles(null);
        try (MockedStatic<Vehicle> mockedStatic = mockStatic(Vehicle.class)) {
            Vehicle vehicle = mock(Vehicle.class);
            EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber("78", "910");
            when(vehicle.getEuropeanVehicleNumber()).thenReturn(europeanVehicleNumber);
            mockedStatic.when(() -> Vehicle.last(any())).thenReturn(vehicle);

            EuropeanVehicleNumber result = formationRun.europeanVehicleNumberLast();

            assertEquals(europeanVehicleNumber, result);
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