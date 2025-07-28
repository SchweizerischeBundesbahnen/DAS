package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import org.springframework.util.CollectionUtils;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class Vehicle {

    private TractionMode tractionMode;
    private String vehicleCategory;
    private List<VehicleUnit> vehicleUnits;
    private EuropeanVehicleNumber europeanVehicleNumber;

    static Vehicle first(List<Vehicle> vehicles) {
        if (CollectionUtils.isEmpty(vehicles)) {
            return null;
        }
        return vehicles.getFirst();
    }

    static Vehicle last(List<Vehicle> vehicles) {
        if (CollectionUtils.isEmpty(vehicles)) {
            return null;
        }
        return vehicles.getLast();
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

    private int calculateHoldingForce() {
        return vehicleUnits.stream().mapToInt(vehicleUnit -> vehicleUnit.calculateHoldingForce(isTraction())).sum();
    }

    private boolean hasBrakeDesign(BrakeDesign... brakeDesigns) {
        return VehicleUnit.hasBrakeDesign(vehicleUnits, brakeDesigns);
    }
}
