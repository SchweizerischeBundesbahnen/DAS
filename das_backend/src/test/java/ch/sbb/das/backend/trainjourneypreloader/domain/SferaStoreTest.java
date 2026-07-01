package ch.sbb.das.backend.trainjourneypreloader.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
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
    void getTc_empty() {
        TrainCharacteristics tc = underTest.getTc(new TrainCharacteristicsIdentification("1", "1", "1", "1"));
        assertThat(tc).isNull();
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
