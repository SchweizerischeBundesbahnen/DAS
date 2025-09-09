package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class Vehicle {

    private TractionMode tractionMode;
    private String vehicleCategory;
    private List<VehicleUnit> vehicleUnits;
    private EuropeanVehicleNumber europeanVehicleNumber;

    static int hauledLoadCount(List<Vehicle> vehicles) {
        return filterHauledLoad(vehicles).size();
    }

    static String getEuropeanVehicleNumberFirst(List<Vehicle> vehicles) {
        List<Vehicle> hauledLoadVehicles = filterHauledLoad(vehicles);
        if (hauledLoadVehicles.isEmpty() || hauledLoadVehicles.getFirst().europeanVehicleNumber == null) {
            return null;
        }
        return hauledLoadVehicles.getFirst().europeanVehicleNumber.toVehicleCode();
    }

    static String getEuropeanVehicleNumberLast(List<Vehicle> vehicles) {
        List<Vehicle> hauledLoadVehicles = filterHauledLoad(vehicles);
        if (hauledLoadVehicles.isEmpty() || hauledLoadVehicles.getLast().europeanVehicleNumber == null) {
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

    static List<TractionMode> tractionModes(List<Vehicle> vehicles) {
        return filterTraction(vehicles).stream().map(vehicle -> vehicle.tractionMode).toList();
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
