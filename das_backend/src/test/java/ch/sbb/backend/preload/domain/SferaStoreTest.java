package ch.sbb.backend.preload.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.backend.preload.sfera.model.v0300.SPZone;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class SferaStoreTest {

    SferaStore underTest;

    @BeforeEach
    void setUp() {
        underTest = new SferaStore();
    }

    @Test
    void getSp_empty() {
        SegmentProfile sp = underTest.getSp(new SegmentProfileIdentification("1", "1", "1", "1", (short) 1));
        assertThat(sp).isNull();
    }

    @Test
    void getTc_empty() {
        TrainCharacteristics tc = underTest.getTc(new TrainCharacteristicsIdentification("1", "1", "1", "1"));
        assertThat(tc).isNull();
    }

    @Test
    void addSps_ok() {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID("SP1");
        sp.setSPVersionMajor("1");
        SPZone spZone = new SPZone();
        spZone.setIMID("0061");
        sp.setSPZone(spZone);
        List<SegmentProfile> sps = List.of(sp);

        underTest.addSps(sps);

        assertThat(underTest.getSp(new SegmentProfileIdentification("SP1", "1", null, "0061", null))).isEqualTo(sp);
    }

    @Test
    void addDuplicateSps_throws() {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID("SPD");
        sp.setSPVersionMajor("2");
        sp.setSPVersionMinor("3");
        SPZone spZone = new SPZone();
        spZone.setIMID("0092");
        sp.setSPZone(spZone);
        List<SegmentProfile> sps = List.of(sp, sp);

        assertThatThrownBy(() -> underTest.addSps(sps)).isInstanceOf(IllegalStateException.class).hasMessageContaining("Duplicate key");
    }

    @Test
    void addTcs_ok() {
        TrainCharacteristics tc = new TrainCharacteristics();
        tc.setTCID("TC1");
        tc.setTCVersionMajor("1");
        tc.setTCVersionMinor("0");
        tc.setTCRUID("1023");
        List<TrainCharacteristics> tcs = List.of(tc);

        underTest.addTcs(tcs);

        assertThat(underTest.getTc(new TrainCharacteristicsIdentification("TC1", "1", "0", "1023"))).isEqualTo(tc);
    }

    @Test
    void addDuplicateTcs_throws() {
        TrainCharacteristics tc = new TrainCharacteristics();
        tc.setTCID("TCD");
        tc.setTCVersionMajor("1");
        tc.setTCRUID("1044");
        List<TrainCharacteristics> tcs = List.of(tc, tc);

        assertThatThrownBy(() -> underTest.addTcs(tcs)).isInstanceOf(IllegalStateException.class).hasMessageContaining("Duplicate key");
    }

}