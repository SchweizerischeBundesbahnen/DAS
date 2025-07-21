package ch.sbb.backend.formation.domain.model;

import java.util.Arrays;
import java.util.List;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@Builder
@EqualsAndHashCode
@ToString
public class VehicleUnit {

    private static final int TON_IN_HECTO_NEWTON = 10;

    private BrakeDesign brakeDesign;
    private BrakeStatus brakeStatus;
    private Integer technicalHoldingForceInHectonewton;
    private Integer effectiveOperationalHoldingForceInHectonewton;
    private Integer handBrakeWeightInTonne;
    private Load load;

    static boolean hasDisabledBrake(List<VehicleUnit> vehicleUnits) {
        if (vehicleUnits == null) {
            return false;
        }
        return vehicleUnits.stream().anyMatch(vehicleUnit -> vehicleUnit.brakeStatus.isDisabled());
    }

    static boolean hasDangerousGoods(List<VehicleUnit> vehicleUnits) {
        if (vehicleUnits == null) {
            return false;
        }
        return vehicleUnits.stream()
            .anyMatch(VehicleUnit::hasDangerousGoods);
    }

    static boolean hasBrakeDesign(List<VehicleUnit> vehicleUnits, BrakeDesign... brakeDesigns) {
        if (vehicleUnits == null) {
            return false;
        }
        return vehicleUnits.stream()
            .anyMatch(vehicleUnit -> vehicleUnit.hasBrakeDesign(brakeDesigns));
    }

    Integer holdingForce(boolean isTraction) {
        if (isTraction) {
            if (technicalHoldingForceInHectonewton != null) {
                return technicalHoldingForceInHectonewton;
            }
        } else {
            if (effectiveOperationalHoldingForceInHectonewton != null) {
                return effectiveOperationalHoldingForceInHectonewton;
            }
        }
        if (handBrakeWeightInTonne != null) {
            return handBrakeWeightInTonne * TON_IN_HECTO_NEWTON;
        }
        return 0;
    }

    private boolean hasBrakeDesign(BrakeDesign... brakeDesigns) {
        if (brakeDesigns == null || brakeDesigns.length == 0) {
            return false;
        }
        return Arrays.asList(brakeDesigns).contains(brakeDesign);
    }

    private boolean hasDangerousGoods() {
        return load != null && load.hasDangerousGoods();
    }
}
