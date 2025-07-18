package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.domain.model.BrakeDesign;
import ch.sbb.backend.formation.domain.model.BrakeStatus;
import ch.sbb.backend.formation.domain.model.EuropeanVehicleNumber;
import ch.sbb.backend.formation.domain.model.Good;
import ch.sbb.backend.formation.domain.model.IntermodalLoadingUnit;
import ch.sbb.backend.formation.domain.model.Load;
import ch.sbb.backend.formation.domain.model.TractionMode;
import ch.sbb.backend.formation.domain.model.Vehicle;
import ch.sbb.backend.formation.domain.model.VehicleUnit;
import ch.sbb.zis.trainformation.api.model.Goods;
import ch.sbb.zis.trainformation.api.model.VehicleGroup;
import java.util.Collections;
import java.util.List;
import java.util.stream.Stream;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public final class VehicleFactory {

    public static List<Vehicle> create(List<VehicleGroup> vehicleGroups) {
        return extractVehicles(vehicleGroups).stream()
            .map(VehicleFactory::create)
            .toList();
    }

    private static List<ch.sbb.zis.trainformation.api.model.Vehicle> extractVehicles(List<VehicleGroup> vehicleGroups) {
        if (vehicleGroups == null) {
            return Collections.emptyList();
        }
        return vehicleGroups.stream()
            .flatMap(group -> group.getVehicles() == null ? Stream.empty() : group.getVehicles().stream())
            .toList();
    }

    private static Vehicle create(ch.sbb.zis.trainformation.api.model.Vehicle vehicle) {
        return new Vehicle(mapToTractionMode(vehicle.getVehicleEffectiveTractionData().getTractionMode()), vehicle.getVehicleCategory(), mapToVehicleUnits(vehicle.getVehicleUnits()),
            new EuropeanVehicleNumber(vehicle.getEuropeanVehicleNumber().getCountryCodeUic(), vehicle.getEuropeanVehicleNumber().getVehicleNumber()));
    }

    private static List<VehicleUnit> mapToVehicleUnits(List<ch.sbb.zis.trainformation.api.model.VehicleUnit> vehicleUnits) {
        return vehicleUnits.stream().map(VehicleFactory::mapToVehicleUnit).toList();
    }

    private static VehicleUnit mapToVehicleUnit(ch.sbb.zis.trainformation.api.model.VehicleUnit vehicleUnit) {
        return new VehicleUnit(mapToBrakeDesign(vehicleUnit.getUnitTechnicalData().getBrakeDesign()), mapToBrakeStatus(vehicleUnit.getUnitEffectiveOperationalData().getBrakeStatus()),
            vehicleUnit.getUnitTechnicalData().getHoldingForceInHectonewton(), vehicleUnit.getUnitEffectiveOperationalData().getHoldingForceInHectonewton(),
            vehicleUnit.getUnitTechnicalData().getHandBrakeWeightInTonne(), mapToLoad(vehicleUnit.getCargoTransport().getLoad()));
    }

    private static Load mapToLoad(ch.sbb.zis.trainformation.api.model.Load load) {
        return new Load(mapToGoodsList(load.getGoods()), mapToIntermodalLoadingUnits(load.getIntermodalLoadingUnits()));
    }

    private static List<IntermodalLoadingUnit> mapToIntermodalLoadingUnits(List<ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit> intermodalLoadingUnits) {
        return intermodalLoadingUnits.stream().map(VehicleFactory::mapToIntermodalLoadingUnit).toList();
    }

    private static IntermodalLoadingUnit mapToIntermodalLoadingUnit(ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit intermodalLoadingUnit) {
        return new IntermodalLoadingUnit(mapToGoodsList(intermodalLoadingUnit.getGoods()));
    }

    private static List<Good> mapToGoodsList(List<Goods> goods) {
        return goods.stream().map(VehicleFactory::mapToGood).toList();
    }

    private static Good mapToGood(Goods goods) {
        return new Good(!goods.getDangerousGoods().isEmpty());
    }

    private static BrakeStatus mapToBrakeStatus(Integer brakeStatus) {
        return new BrakeStatus(brakeStatus);
    }

    private static BrakeDesign mapToBrakeDesign(Integer brakeDesign) {
        return BrakeDesign.valueOfKey(brakeDesign);
    }

    private static TractionMode mapToTractionMode(String tractionMode) {
        return TractionMode.valueOfKey(tractionMode);
    }
}
