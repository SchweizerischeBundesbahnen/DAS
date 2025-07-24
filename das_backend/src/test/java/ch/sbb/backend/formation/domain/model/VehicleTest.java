package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;
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

        assertThat(vehicle.getTractionMode()).isEqualTo(TractionMode.ZUGLOK);
        assertThat(vehicle.getEuropeanVehicleNumber()).isEqualTo(europeanVehicleNumber);
    }

    @Test
    void first_withMultipleVehicles() {
        Vehicle vehicle1 = createVehicle();
        Vehicle vehicle2 = createVehicle();
        List<Vehicle> vehicles = List.of(vehicle1, vehicle2);

        Vehicle result = Vehicle.first(vehicles);

        assertThat(result).isEqualTo(vehicle1);
    }

    @Test
    void last_withMultipleVehicles() {
        Vehicle vehicle1 = createVehicle();
        Vehicle vehicle2 = createVehicle();
        List<Vehicle> vehicles = List.of(vehicle1, vehicle2);

        Vehicle result = Vehicle.last(vehicles);

        assertThat(result).isEqualTo(vehicle2);
    }

    @Test
    void firstAndLast_whenOnlyOneVehicle() {
        Vehicle vehicle = createVehicle();
        List<Vehicle> vehicles = List.of(vehicle);

        Vehicle firstResult = Vehicle.first(vehicles);
        Vehicle lastResult = Vehicle.last(vehicles);

        assertThat(firstResult).isEqualTo(vehicle);
        assertThat(lastResult).isEqualTo(vehicle);
    }

    @Test
    void hasDangerousGoods_withEmpty() {
        List<Vehicle> vehicles = Collections.emptyList();

        boolean result = Vehicle.hasDangerousGoods(vehicles);

        assertThat(result).isFalse();
    }

    @Test
    void hasDangerousGoods_withDangerous() {
        Vehicle vehicle = createVehicle();
        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasDangerousGoods(any())).thenReturn(true);

            assertThat(vehicle.hasDangerousGoods()).isTrue();
        }
    }

    @Test
    void hasDangerousGoods_withNotDangerous() {
        List<Vehicle> vehicles = List.of(createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasDangerousGoods(any())).thenReturn(true);

            assertThat(Vehicle.hasDangerousGoods(vehicles)).isTrue();
        }
    }

    @Test
    void countBrakeDesigns_hasTwo() {
        List<Vehicle> vehicles = List.of(createVehicle(), createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasBrakeDesign(any(), any())).thenReturn(true);

            assertThat(Vehicle.countBrakeDesigns(vehicles, BrakeDesign.EINLOESIGE_BREMSE)).isEqualTo(2);
        }
    }

    @Test
    void countBrakeDesigns_hasNone() {
        List<Vehicle> vehicles = List.of(createVehicle(), createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasBrakeDesign(any(), any())).thenReturn(false);

            assertThat(Vehicle.countBrakeDesigns(vehicles, BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE)).isZero();
        }
    }

    @Test
    void countDisabledBrakes_hasOne() {
        List<Vehicle> vehicles = List.of(createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasDisabledBrake(any())).thenReturn(true);

            assertThat(Vehicle.countDisabledBrakes(vehicles)).isEqualTo(1);
        }
    }

    @Test
    void calculateHoldingForce_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.calculateHoldingForce(anyBoolean())).thenReturn(100);
        Vehicle vehicle1 = new Vehicle(null, null, List.of(vehicleUnit, vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit), null);

        Integer result = Vehicle.calculateHoldingForce(List.of(vehicle1, vehicle2));

        assertThat(result).isEqualTo(300);
    }

    @Test
    void tractionCalculateHoldingForceInHectoNewton_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.calculateHoldingForce(anyBoolean())).thenReturn(20);
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), List.of(vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit), null);

        Integer result = Vehicle.calculateTractionHoldingForceInHectoNewton(List.of(vehicle1, vehicle2));

        assertThat(result).isEqualTo(20);
    }

    @Test
    void hauledLoadCalculateHoldingForceInHectoNewton_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.calculateHoldingForce(anyBoolean())).thenReturn(30);
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), List.of(vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit, vehicleUnit), null);

        Integer result = Vehicle.calculateHauledLoadHoldingForceInHectoNewton(List.of(vehicle1, vehicle2));

        assertThat(result).isEqualTo(60);
    }

    @Test
    void isTraction_false() {
        Vehicle vehicle = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null);

        boolean result = vehicle.isTraction();

        assertThat(result).isFalse();
    }

    @Test
    void isTraction_true() {
        Vehicle vehicle = new Vehicle(TractionMode.DOPPELTRAKTION, VehicleCategory.TRIEBWAGEN.name(), null, null);

        boolean result = vehicle.isTraction();

        assertThat(result).isTrue();
    }

    @Test
    void isTraction_withSchlepplok() {
        Vehicle vehicle = new Vehicle(TractionMode.SCHLEPPLOK, VehicleCategory.LOKOMOTIVE.name(), null, null);

        boolean result = vehicle.isTraction();

        assertThat(result).isFalse();
    }

    private Vehicle createVehicle() {
        return new Vehicle(null, null, null, null);
    }
}