package ch.sbb.backend.formation.domain.model;

import java.util.Collections;
import java.util.List;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class Vehicle {

    private TractionMode tractionMode;
    private String vehicleCategory;
    private List<VehicleUnit> vehicleUnits;
    private EuropeanVehicleNumber europeanVehicleNumber;

    static Vehicle first(List<Vehicle> vehicles) {
        if (vehicles == null || vehicles.isEmpty()) {
            return null;
        }
        return vehicles.getFirst();
    }

    static Vehicle last(List<Vehicle> vehicles) {
        if (vehicles == null || vehicles.isEmpty()) {
            return null;
        }
        return vehicles.getLast();
    }

    static boolean hasDangerousGoods(List<Vehicle> vehicles) {
        if (vehicles == null) {
            return false;
        }
        return vehicles.stream()
            .anyMatch(Vehicle::hasDangerousGoods);
    }

    static Integer brakeDesignCount(List<Vehicle> vehicles, BrakeDesign... brakeDesigns) {
        return (int) vehicles.stream().filter(vehicle -> vehicle.hasBrakeDesign(brakeDesigns)).count();
    }

    static Integer disabledBrakeCount(List<Vehicle> vehicles) {
        return (int) vehicles.stream().filter(Vehicle::hasDisabledBrake).count();
    }

    static Integer holdingForce(List<Vehicle> vehicles) {
        return vehicles.stream().mapToInt(Vehicle::holdingForce).sum();
    }

    static Integer tractionHoldingForceInHectoNewton(List<Vehicle> vehicles) {
        return Vehicle.holdingForce(Vehicle.filterTraction(vehicles));
    }

    static Integer hauledLoadHoldingForceInHectoNewton(List<Vehicle> vehicles) {
        return Vehicle.holdingForce(Vehicle.filterHauledLoad(vehicles));
    }

    private static List<Vehicle> filterHauledLoad(List<Vehicle> vehicles) {
        if (vehicles == null) {
            return Collections.emptyList();
        }
        return vehicles.stream()
            .filter(vehicle -> !vehicle.isTraction())
            .toList();
    }

    private static List<Vehicle> filterTraction(List<Vehicle> vehicles) {
        if (vehicles == null) {
            return Collections.emptyList();
        }
        return vehicles.stream()
            .filter(Vehicle::isTraction)
            .toList();
    }

    boolean isTraction() {
        return TractionMode.SCHLEPPLOK != this.tractionMode &&
            (VehicleCategory.LOKOMOTIVE.name().equals(this.vehicleCategory) || VehicleCategory.TRIEBWAGEN.name().equals(this.vehicleCategory) || VehicleCategory.GLIEDERFAHRZEUG.name()
                .equals(this.vehicleCategory));
    }

    boolean hasDangerousGoods() {
        return VehicleUnit.hasDangerousGoods(vehicleUnits);
    }

    TractionMode getTractionMode() {
        return tractionMode;
    }

    EuropeanVehicleNumber getEuropeanVehicleNumber() {
        return europeanVehicleNumber;
    }

    private boolean hasDisabledBrake() {
        return VehicleUnit.hasDisabledBrake(vehicleUnits);
    }

    private int holdingForce() {
        return vehicleUnits.stream().mapToInt(vehicleUnit -> vehicleUnit.holdingForce(isTraction())).sum();
    }

    private boolean hasBrakeDesign(BrakeDesign... brakeDesigns) {
        return VehicleUnit.hasBrakeDesign(vehicleUnits, brakeDesigns);
    }

}
