package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

class VehicleUnitTest {

    @Test
    void hasDisabledBrake_true() {
        BrakeStatus disabledBrakestatus = mock(BrakeStatus.class);
        when(disabledBrakestatus.isDisabled()).thenReturn(true);

        BrakeStatus nonDisabledBrakestatus = mock(BrakeStatus.class);
        when(nonDisabledBrakestatus.isDisabled()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, disabledBrakestatus, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(null, nonDisabledBrakestatus, null, null, null, null));

        boolean result = VehicleUnit.hasDisabledBrake(vehicleUnits);

        assertThat(result).isTrue();
    }

    @Test
    void hasDisabledBrake_false() {
        BrakeStatus nonDisabledBrakestatus = mock(BrakeStatus.class);
        when(nonDisabledBrakestatus.isDisabled()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, nonDisabledBrakestatus, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(null, nonDisabledBrakestatus, null, null, null, null));

        boolean result = VehicleUnit.hasDisabledBrake(vehicleUnits);

        assertThat(result).isFalse();
    }

    @Test
    void hasDangerousGoods_true() {
        Load dangerousGoodsLoad = mock(Load.class);
        when(dangerousGoodsLoad.hasDangerousGoods()).thenReturn(true);

        Load nonDangerousGoodsLoad = mock(Load.class);
        when(nonDangerousGoodsLoad.hasDangerousGoods()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, dangerousGoodsLoad));
        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, nonDangerousGoodsLoad));

        boolean result = VehicleUnit.hasDangerousGoods(vehicleUnits);

        assertThat(result).isTrue();
    }

    @Test
    void hasDangerousGoods_false() {
        Load nonDangerousGoodsLoad = mock(Load.class);
        when(nonDangerousGoodsLoad.hasDangerousGoods()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, nonDangerousGoodsLoad));
        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, nonDangerousGoodsLoad));

        boolean result = VehicleUnit.hasDangerousGoods(vehicleUnits);

        assertThat(result).isFalse();
    }

    @Test
    void hasBrakeDesign_true() {
        List<VehicleUnit> vehicleUnits = new ArrayList<>();
        vehicleUnits.add(new VehicleUnit(BrakeDesign.EINLOESIGE_BREMSE, null, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(BrakeDesign.SCHEIBENBREMSEN, null, null, null, null, null));

        boolean result = VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.EINLOESIGE_BREMSE);

        assertThat(result).isTrue();
    }

    @Test
    void hasBrakeDesign_false() {
        List<VehicleUnit> vehicleUnits = new ArrayList<>();
        vehicleUnits.add(new VehicleUnit(BrakeDesign.L_KUNSTSTOFF_LEISE, null, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(BrakeDesign.NICHT_KODIERT, null, null, null, null, null));

        boolean result = VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.SCHEIBENBREMSEN);

        assertThat(result).isFalse();
    }

    @Test
    void hasBrakeDesign_multipleBrakeDesign() {
        List<VehicleUnit> vehicleUnits = new ArrayList<>();
        vehicleUnits.add(new VehicleUnit(BrakeDesign.L_KUNSTSTOFF_LEISE, null, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(BrakeDesign.NICHT_KODIERT, null, null, null, null, null));

        assertThat(VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.SCHEIBENBREMSEN, BrakeDesign.NICHT_KODIERT)).isTrue();
        assertThat(VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.NICHT_KODIERT, BrakeDesign.L_KUNSTSTOFF_LEISE)).isTrue();
        assertThat(VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE, BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE)).isFalse();
    }

    @Test
    void calculateCalculateHoldingForce_null() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, null, null, null, null);

        Integer result = vehicleUnit.calculateHoldingForce(true);

        assertThat(result).isZero();
    }

    @Test
    void calculateCalculateHoldingForce_whenTraction() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, 13, 22, 10, null);

        Integer result = vehicleUnit.calculateHoldingForce(true);

        assertThat(result).isEqualTo(13);
    }

    @Test
    void holdingForce_whenTractionNoCalculateCalculateHoldingForce() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, null, 22, 10, null);

        Integer result = vehicleUnit.calculateHoldingForce(true);

        assertThat(result).isEqualTo(100);
    }

    @Test
    void calculateCalculateHoldingForce_whenNotTraction() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, 34, 12, 7, null);

        Integer result = vehicleUnit.calculateHoldingForce(false);

        assertThat(result).isEqualTo(12);
    }

    @Test
    void holdingForce_whenNotTractionNoCalculateCalculateHoldingForce() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, 34, null, 9, null);

        Integer result = vehicleUnit.calculateHoldingForce(false);

        assertThat(result).isEqualTo(90);
    }
}