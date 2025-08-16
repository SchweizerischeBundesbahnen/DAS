package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import lombok.extern.slf4j.Slf4j;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
@Slf4j
public class Vehicle {

    private static final List<TractionMode> SPECIAL_TRACTION_MODES = List.of(TractionMode.ZWISCHENLOK, TractionMode.SCHIEBELOK, TractionMode.UEBERFUEHRUNG);
    private TractionMode tractionMode;
    private String vehicleCategory;
    private List<VehicleUnit> vehicleUnits;
    private EuropeanVehicleNumber europeanVehicleNumber;

    static int hauledLoadCount(List<Vehicle> vehicles) {
        return filterHauledLoad(vehicles).size();
    }

    static String europeanVehicleNumberFirst(List<Vehicle> vehicles) {
        List<Vehicle> hauledLoadVehicles = filterHauledLoad(vehicles);
        if (hauledLoadVehicles.isEmpty()) {
            return null;
        }
        return hauledLoadVehicles.getFirst().europeanVehicleNumber.toVehicleCode();
    }

    static String europeanVehicleNumberLast(List<Vehicle> vehicles) {
        List<Vehicle> hauledLoadVehicles = filterHauledLoad(vehicles);
        if (hauledLoadVehicles.isEmpty()) {
            return null;
        }
        return hauledLoadVehicles.getLast().europeanVehicleNumber.toVehicleCode();
    }

    static boolean hasDangerousGoods(List<Vehicle> vehicles) {
        return vehicles.stream()
            .anyMatch(Vehicle::hasDangerousGoods);
    }

    static Integer countBrakeDesigns(List<Vehicle> vehicles, BrakeDesign... brakeDesigns) {
        return (int) vehicles.stream().filter(vehicle -> vehicle.hasBrakeDesign(brakeDesigns)).count();
    }

    static Integer countDisabledBrakes(List<Vehicle> vehicles) {
        return (int) vehicles.stream().filter(Vehicle::hasDisabledBrake).count();
    }

    static Integer calculateHoldingForce(List<Vehicle> vehicles) {
        return vehicles.stream().mapToInt(Vehicle::calculateHoldingForce).sum();
    }

    static Integer calculateTractionHoldingForceInHectoNewton(List<Vehicle> vehicles) {
        return Vehicle.calculateHoldingForce(Vehicle.filterTraction(vehicles));
    }

    static Integer calculateHauledLoadHoldingForceInHectoNewton(List<Vehicle> vehicles) {
        return Vehicle.calculateHoldingForce(Vehicle.filterHauledLoad(vehicles));
    }

    private static List<Vehicle> filterHauledLoad(List<Vehicle> vehicles) {
        return vehicles.stream()
            .filter(vehicle -> !vehicle.isTraction())
            .toList();
    }

    private static List<Vehicle> filterTraction(List<Vehicle> vehicles) {
        return vehicles.stream()
            .filter(Vehicle::isTraction)
            .toList();
    }

    static TractionMode specialTractionMode(List<Vehicle> vehicles) {
        Vehicle vehicle = specialTraction(vehicles);
        if (vehicle == null) {
            return null;
        }
        return vehicle.tractionMode;
    }

    static String specialTractionSeries(List<Vehicle> vehicles) {
        Vehicle vehicle = specialTraction(vehicles);
        if (vehicle == null) {
            return null;
        }
        if (vehicle.vehicleUnits.size() != 1) {
            log.error("Traction vehicle with no or more than one vehicleUnit found: {}", vehicle.vehicleUnits);
            return null;
        }
        return vehicle.vehicleUnits.getFirst().getVehicleTypeIdentifier();
    }

    private static Vehicle specialTraction(List<Vehicle> vehicles) {
        List<Vehicle> specialTractionVehicles = filterTraction(vehicles).stream().filter(vehicle -> SPECIAL_TRACTION_MODES.contains(vehicle.tractionMode)).toList();
        if (specialTractionVehicles.isEmpty()) {
            return null;
        }
        if (specialTractionVehicles.size() > 1) {
            log.error("Multiple traction vehicles with special traction found: {}", specialTractionVehicles);
            return null;
        }
        return specialTractionVehicles.getFirst();
    }

    private boolean isTraction() {
        return TractionMode.SCHLEPPLOK != this.tractionMode &&
            (VehicleCategory.LOKOMOTIVE.name().equals(this.vehicleCategory) || VehicleCategory.TRIEBWAGEN.name().equals(this.vehicleCategory) || VehicleCategory.GLIEDERFAHRZEUG.name()
                .equals(this.vehicleCategory));
    }

    private boolean hasDangerousGoods() {
        return VehicleUnit.hasDangerousGoods(vehicleUnits);
    }

    private boolean hasDisabledBrake() {
        return VehicleUnit.hasDisabledBrake(vehicleUnits);
    }

    private int calculateHoldingForce() {
        return vehicleUnits.stream().mapToInt(vehicleUnit -> vehicleUnit.calculateHoldingForce(isTraction())).sum();
    }

    private boolean hasBrakeDesign(BrakeDesign... brakeDesigns) {
        return VehicleUnit.hasBrakeDesign(vehicleUnits, brakeDesigns);
    }
}
