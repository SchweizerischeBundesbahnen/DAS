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
    void hauledLoadCount_withEmpty() {
        List<Vehicle> vehicles = Collections.emptyList();

        int result = Vehicle.hauledLoadCount(vehicles);

        assertThat(result).isZero();
    }

    @Test
    void hauledLoadCount_withOnlyTraction() {
        List<Vehicle> vehicles = List.of(
            new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null),
            new Vehicle(TractionMode.DOPPELTRAKTION, VehicleCategory.TRIEBWAGEN.name(), null, null));

        int result = Vehicle.hauledLoadCount(vehicles);

        assertThat(result).isZero();
    }

    @Test
    void hauledLoadCount_withTractionAndHauledLoad() {
        List<Vehicle> vehicles = List.of(
            new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null),
            new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null),
            new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null),
            new Vehicle(TractionMode.SCHIEBELOK, VehicleCategory.TRIEBWAGEN.name(), null, null));

        int result = Vehicle.hauledLoadCount(vehicles);

        assertThat(result).isEqualTo(2);
    }

    @Test
    void hauledLoadCount_withSchlepplok() {
        List<Vehicle> vehicles = List.of(
            new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null),
            new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null),
            new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null),
            new Vehicle(null, VehicleCategory.ANHAENGELAST.name(), null, null),
            new Vehicle(TractionMode.SCHLEPPLOK, VehicleCategory.LOKOMOTIVE.name(), null, null));

        int result = Vehicle.hauledLoadCount(vehicles);

        assertThat(result).isEqualTo(4);
    }

    @Test
    void europeanVehicleNumbers_withEmpty() {
        List<Vehicle> vehicles = Collections.emptyList();

        String first = Vehicle.europeanVehicleNumberLast(vehicles);
        String last = Vehicle.europeanVehicleNumberFirst(vehicles);

        assertThat(first).isNull();
        assertThat(last).isNull();
    }

    @Test
    void europeanVehicleNumbers_withMultipleVehicles() {
        EuropeanVehicleNumber firstEvnMock = mock(EuropeanVehicleNumber.class);
        when(firstEvnMock.toVehicleCode()).thenReturn("34562342341");
        EuropeanVehicleNumber lastEvnMock = mock(EuropeanVehicleNumber.class);
        when(lastEvnMock.toVehicleCode()).thenReturn("34324346134");

        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        Vehicle vehicle2 = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, firstEvnMock);
        Vehicle vehicle3 = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null);
        Vehicle vehicle4 = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, lastEvnMock);
        List<Vehicle> vehicles = List.of(vehicle1, vehicle2, vehicle3, vehicle4);

        String first = Vehicle.europeanVehicleNumberFirst(vehicles);
        String last = Vehicle.europeanVehicleNumberLast(vehicles);

        assertThat(first).isEqualTo("34562342341");
        assertThat(last).isEqualTo("34324346134");
    }

    @Test
    void europeanVehicleNumbers_whenOnlyOneHauledLoad() {
        EuropeanVehicleNumber evnMock = mock(EuropeanVehicleNumber.class);
        when(evnMock.toVehicleCode()).thenReturn("425859349349");

        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        Vehicle vehicle2 = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, evnMock);
        Vehicle vehicle3 = new Vehicle(TractionMode.SCHIEBELOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        List<Vehicle> vehicles = List.of(vehicle1, vehicle2, vehicle3);

        String first = Vehicle.europeanVehicleNumberFirst(vehicles);
        String last = Vehicle.europeanVehicleNumberLast(vehicles);

        assertThat(first).isEqualTo("425859349349");
        assertThat(last).isEqualTo("425859349349");
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

            assertThat(Vehicle.hasDangerousGoods(List.of(vehicle))).isTrue();
        }
    }

    @Test
    void hasDangerousGoods_withoutDangerous() {
        List<Vehicle> vehicles = List.of(createVehicle());

        try (MockedStatic<VehicleUnit> mockedStatic = mockStatic(VehicleUnit.class)) {
            mockedStatic.when(() -> VehicleUnit.hasDangerousGoods(any())).thenReturn(false);

            assertThat(Vehicle.hasDangerousGoods(vehicles)).isFalse();
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
    void calculateTractionHoldingForceInHectoNewton_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.calculateHoldingForce(anyBoolean())).thenReturn(20);
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), List.of(vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit), null);

        Integer result = Vehicle.calculateTractionHoldingForceInHectoNewton(List.of(vehicle1, vehicle2));

        assertThat(result).isEqualTo(20);
    }

    @Test
    void calculateHauledLoadHoldingForceInHectoNewton_withMultipleVehicles() {
        VehicleUnit vehicleUnit = mock(VehicleUnit.class);
        when(vehicleUnit.calculateHoldingForce(anyBoolean())).thenReturn(30);
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), List.of(vehicleUnit), null);
        Vehicle vehicle2 = new Vehicle(null, null, List.of(vehicleUnit, vehicleUnit), null);

        Integer result = Vehicle.calculateHauledLoadHoldingForceInHectoNewton(List.of(vehicle1, vehicle2));

        assertThat(result).isEqualTo(60);
    }

    @Test
    void specialTractionMode_empty() {
        TractionMode result = Vehicle.specialTractionMode(Collections.emptyList());

        assertThat(result).isNull();
    }

    @Test
    void specialTractionMode_withMultipleVehicles() {
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        Vehicle vehicle2 = new Vehicle(TractionMode.SCHIEBELOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        Vehicle vehicle3 = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null);

        TractionMode result = Vehicle.specialTractionMode(List.of(vehicle1, vehicle2, vehicle3));

        assertThat(result).isEqualTo(TractionMode.SCHIEBELOK);
    }

    @Test
    void specialTractionMode_withInconsistentData() {
        Vehicle vehicle1 = new Vehicle(TractionMode.SCHIEBELOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        Vehicle vehicle2 = new Vehicle(TractionMode.UEBERFUEHRUNG, VehicleCategory.LOKOMOTIVE.name(), null, null);

        TractionMode result = Vehicle.specialTractionMode(List.of(vehicle1, vehicle2));

        assertThat(result).isNull();
    }

    @Test
    void specialTractionSeries_empty() {
        String result = Vehicle.specialTractionSeries(Collections.emptyList());

        assertThat(result).isNull();
    }

    @Test
    void specialTractionSeries_withMultipleVehicles() {
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        Vehicle vehicle2 = new Vehicle(TractionMode.ZWISCHENLOK, VehicleCategory.TRIEBWAGEN.name(), List.of(new VehicleUnit(null, null, null, null, null, null, "Rm84")), null);
        Vehicle vehicle3 = new Vehicle(null, VehicleCategory.GUETERWAGEN.name(), null, null);

        String result = Vehicle.specialTractionSeries(List.of(vehicle1, vehicle2, vehicle3));

        assertThat(result).isEqualTo("Rm84");
    }

    @Test
    void specialTractionSeries_withMoreThanOneVehicleUnit() {
        Vehicle vehicle1 = new Vehicle(TractionMode.ZUGLOK, VehicleCategory.LOKOMOTIVE.name(), null, null);
        Vehicle vehicle2 = new Vehicle(TractionMode.ZWISCHENLOK, VehicleCategory.TRIEBWAGEN.name(),
            List.of(new VehicleUnit(null, null, null, null, null, null, "Rm84"), new VehicleUnit(null, null, null, null, null, null, "Rm84")), null);

        String result = Vehicle.specialTractionSeries(List.of(vehicle1, vehicle2));

        assertThat(result).isNull();
    }

    private Vehicle createVehicle() {
        return new Vehicle(null, null, null, null);
    }
}