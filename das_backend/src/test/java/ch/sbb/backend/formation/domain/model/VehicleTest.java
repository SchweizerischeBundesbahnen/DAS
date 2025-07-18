package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.when;

import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

class VehicleTest {

    @Test
    void constructor_getters() {
        EuropeanVehicleNumber europeanVehicleNumber = new EuropeanVehicleNumber("86", "12345");
        Vehicle vehicle = new Vehicle(TractionMode.ZUGLOK, null, null, europeanVehicleNumber);

        assertEquals(TractionMode.ZUGLOK, vehicle.getTractionMode());
        assertEquals(europeanVehicleNumber, vehicle.getEuropeanVehicleNumber());
    }

    @Test
    void first_withMultipleVehicles() {
        Vehicle vehicle1 = createVehicle();
        Vehicle vehicle2 = createVehicle();
        List<Vehicle> vehicles = List.of(vehicle1, vehicle2);

        Vehicle result = Vehicle.first(vehicles);

        assertEquals(vehicle1, result);
    }

    @Test
    void last_withMultipleVehicles() {
        Vehicle vehicle1 = createVehicle();
        Vehicle vehicle2 = createVehicle();
        List<Vehicle> vehicles = List.of(vehicle1, vehicle2);

        Vehicle result = Vehicle.last(vehicles);

        assertEquals(vehicle2, result);
    }

    @Test
    void firstAndLast_whenOnlyOneVehicle() {
        Vehicle vehicle = createVehicle();
        List<Vehicle> vehicles = List.of(vehicle);

        Vehicle firstResult = Vehicle.first(vehicles);
        Vehicle lastResult = Vehicle.last(vehicles);

        assertEquals(vehicle, firstResult);
        assertEquals(vehicle, lastResult);
    }

    @Test
    void hasDangerousGoods_withNull() {
        boolean result = Vehicle.hasDangerousGoods(null);

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_withEmpty() {
        List<Vehicle> vehicles = Collections.emptyList();

        boolean result = Vehicle.hasDangerousGoods(vehicles);

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_withDangerous() {
        Vehicle vehicle = createVehicle();
        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasDangerousGoods(any())).thenReturn(true);

            assertTrue(vehicle.hasDangerousGoods());
        }
    }

    @Test
    void hasDangerousGoods_withNotDangerous() {
        List<Vehicle> vehicles = List.of(createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasDangerousGoods(any())).thenReturn(true);

            assertTrue(Vehicle.hasDangerousGoods(vehicles));
        }
    }

    @Test
    void brakeDesignCount_hasTwo() {
        List<Vehicle> vehicles = List.of(createVehicle(), createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasBrakeDesign(any(), any())).thenReturn(true);

            assertEquals(2, Vehicle.brakeDesignCount(vehicles, BrakeDesign.EINLOESIGE_BREMSE));
        }
    }

    @Test
    void brakeDesignCount_hasNone() {
        List<Vehicle> vehicles = List.of(createVehicle(), createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasBrakeDesign(any(), any())).thenReturn(false);

            assertEquals(0, Vehicle.brakeDesignCount(vehicles, BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE));
        }
    }

    @Test
    void disabledBrakeCount_hasOne() {
        List<Vehicle> vehicles = List.of(createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasDisabledBrake(any())).thenReturn(true);

            assertEquals(1, Vehicle.disabledBrakeCount(vehicles));
        }
    }

    @Test
    void holdingForce_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.holdingForce(anyBoolean())).thenReturn(100);
        Vehicle vehicle1 = new Vehicle(null, null, List.of(vehicleUnit, vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit), null);

        Integer result = Vehicle.holdingForce(List.of(vehicle1, vehicle2));

        assertEquals(300, result);
    }

    @Test
    void tractionHoldingForceInHectoNewton_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.holdingForce(anyBoolean())).thenReturn(20);
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), List.of(vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit), null);

        Integer result = Vehicle.tractionHoldingForceInHectoNewton(List.of(vehicle1, vehicle2));

        assertEquals(20, result);
    }

    @Test
    void hauledLoadHoldingForceInHectoNewton_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.holdingForce(anyBoolean())).thenReturn(30);
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), List.of(vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit, vehicleUnit), null);

        Integer result = Vehicle.hauledLoadHoldingForceInHectoNewton(List.of(vehicle1, vehicle2));

        assertEquals(60, result);
    }

    @Test
    void isTraction_false() {
        Vehicle vehicle = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null);

        boolean result = vehicle.isTraction();

        assertFalse(result);
    }

    @Test
    void isTraction_true() {
        Vehicle vehicle = new Vehicle(TractionMode.DOPPELTRAKTION, VehicleCategory.TRIEBWAGEN.name(), null, null);

        boolean result = vehicle.isTraction();

        assertTrue(result);
    }

    @Test
    void isTraction_withSchlepplok() {
        Vehicle vehicle = new Vehicle(TractionMode.SCHLEPPLOK, VehicleCategory.LOKOMOTIVE.name(), null, null);

        boolean result = vehicle.isTraction();

        assertFalse(result);
    }

    private Vehicle createVehicle() {
        return new Vehicle(null, null, null, null);
    }
}