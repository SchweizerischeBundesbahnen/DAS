package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class TafTapLocationReferenceTest {

    @Test
    void toLocationCode_null() {
        TafTapLocationReference reference = new TafTapLocationReference(null, null);
        String result = reference.toLocationCode();
        assertThat(result).isNull();
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCode() {
        TafTapLocationReference reference = new TafTapLocationReference(12, 34567);
        String result = reference.toLocationCode();
        assertThat(result).isEqualTo("1234567");
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCodeWith0() {
        TafTapLocationReference reference = new TafTapLocationReference(5, 23);
        String result = reference.toLocationCode();
        assertThat(result).isEqualTo("0500023");
    }
}