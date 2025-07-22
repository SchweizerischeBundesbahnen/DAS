package ch.sbb.backend.formation.infrastructure;

import static org.junit.jupiter.api.Assertions.assertEquals;

import ch.sbb.backend.formation.domain.model.BrakeDesign;
import ch.sbb.backend.formation.domain.model.BrakeStatus;
import ch.sbb.backend.formation.domain.model.EuropeanVehicleNumber;
import ch.sbb.backend.formation.domain.model.Goods;
import ch.sbb.backend.formation.domain.model.IntermodalLoadingUnit;
import ch.sbb.backend.formation.domain.model.Load;
import ch.sbb.backend.formation.domain.model.TractionMode;
import ch.sbb.backend.formation.domain.model.Vehicle;
import ch.sbb.backend.formation.domain.model.VehicleUnit;
import ch.sbb.zis.trainformation.api.model.CargoTransport;
import ch.sbb.zis.trainformation.api.model.DangerousGoods;
import ch.sbb.zis.trainformation.api.model.UnitEffectiveOperationalData;
import ch.sbb.zis.trainformation.api.model.UnitTechnicalData;
import ch.sbb.zis.trainformation.api.model.VehicleEffectiveTractionData;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;

class VehicleFactoryTest {

    @Test
    void create() {

        ch.sbb.zis.trainformation.api.model.VehicleGroup vehicleGroup1 = new ch.sbb.zis.trainformation.api.model.VehicleGroup();
        ch.sbb.zis.trainformation.api.model.Vehicle vehicle1 = createVehicle();
        vehicle1.setVehicleEffectiveTractionData(new VehicleEffectiveTractionData(null, "STAMMLOK"));
        vehicle1.setVehicleCategory("LOKOMOTIVE");
        vehicle1.setVehicleUnits(List.of(createVehicleUnit()));
        vehicle1.setEuropeanVehicleNumber(new ch.sbb.zis.trainformation.api.model.EuropeanVehicleNumber("1", "46", "", "334455"));
        vehicleGroup1.setVehicles(List.of(vehicle1));

        ch.sbb.zis.trainformation.api.model.VehicleGroup vehicleGroup2 = new ch.sbb.zis.trainformation.api.model.VehicleGroup();
        vehicleGroup2.setVehicles(List.of(createVehicle(), createVehicle()));
        List<Vehicle> result = VehicleFactory.create(List.of(vehicleGroup1, vehicleGroup2));

        Vehicle expectedVehicle1 = new Vehicle(TractionMode.ZUGLOK, "LOKOMOTIVE",
            List.of(
                VehicleUnit.builder()
                    .brakeDesign(BrakeDesign.SCHEIBENBREMSEN)
                    .brakeStatus(new BrakeStatus(3))
                    .technicalHoldingForceInHectoNewton(92)
                    .effectiveOperationalHoldingForceInHectoNewton(342)
                    .handBrakeWeightInT(12)
                    .load(new Load(List.of(new Goods(true)), List.of(new IntermodalLoadingUnit(List.of(new Goods(false))))))
                    .build()),
            new EuropeanVehicleNumber("46", "334455"));

        Vehicle expectedOtherVehicle = new Vehicle(null, null, Collections.emptyList(), null);

        assertEquals(3, result.size());
        assertEquals(expectedVehicle1, result.getFirst());
        assertEquals(expectedOtherVehicle, result.get(1));
        assertEquals(expectedOtherVehicle, result.get(2));

    }

    private ch.sbb.zis.trainformation.api.model.VehicleUnit createVehicleUnit() {
        ch.sbb.zis.trainformation.api.model.Goods goodsWithDangerousGoods = new ch.sbb.zis.trainformation.api.model.Goods();
        goodsWithDangerousGoods.setDangerousGoods(List.of(new DangerousGoods()));

        ch.sbb.zis.trainformation.api.model.Goods goodsWithoutDangerousGoods = new ch.sbb.zis.trainformation.api.model.Goods();

        ch.sbb.zis.trainformation.api.model.VehicleUnit vehicleUnit = new ch.sbb.zis.trainformation.api.model.VehicleUnit();
        ch.sbb.zis.trainformation.api.model.Load load = new ch.sbb.zis.trainformation.api.model.Load();
        ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit intermodalLoadingUnit = new ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit();

        load.setGoods(List.of(goodsWithDangerousGoods));
        intermodalLoadingUnit.setGoods(List.of(goodsWithoutDangerousGoods));
        load.setIntermodalLoadingUnits(List.of(intermodalLoadingUnit));
        vehicleUnit.setCargoTransport(new CargoTransport(null, load, null, null));
        UnitTechnicalData unitTechnicalData = new UnitTechnicalData();
        unitTechnicalData.setBrakeDesign(1);
        unitTechnicalData.setHoldingForceInHectonewton(92);
        unitTechnicalData.setHandBrakeWeightInTonne(12);
        vehicleUnit.setUnitTechnicalData(unitTechnicalData);

        UnitEffectiveOperationalData unitEffectiveOperationalData = new UnitEffectiveOperationalData();
        unitEffectiveOperationalData.setBrakeStatus(3);
        unitEffectiveOperationalData.setHoldingForceInHectonewton(342);
        vehicleUnit.setUnitEffectiveOperationalData(unitEffectiveOperationalData);
        return vehicleUnit;

    }

    private ch.sbb.zis.trainformation.api.model.Vehicle createVehicle() {
        return new ch.sbb.zis.trainformation.api.model.Vehicle();
    }
}