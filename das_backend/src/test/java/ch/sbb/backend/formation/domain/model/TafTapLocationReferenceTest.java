package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import org.junit.jupiter.api.Test;

class TafTapLocationReferenceTest {

    @Test
    void toLocationCode_null() {
        TafTapLocationReference reference = new TafTapLocationReference(null, null);

        assertThatExceptionOfType(UnexpectedProviderData.class).isThrownBy(() -> reference.toLocationCode());
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCode() {
        TafTapLocationReference reference = new TafTapLocationReference("CH", 34567);
        String result = reference.toLocationCode();
        assertThat(result).isEqualTo("CH34567");
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCodeWith0() {
        TafTapLocationReference reference = new TafTapLocationReference("CH", 23);
        String result = reference.toLocationCode();
        assertThat(result).isEqualTo("CH00023");
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCodeWithOtherCountry() {
        TafTapLocationReference reference = new TafTapLocationReference("DE", 75985);
        String result = reference.toLocationCode();
        assertThat(result).isEqualTo("DE75985");
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCodeWithTooLongUicCode() {
        TafTapLocationReference reference = new TafTapLocationReference("CH", 25675673);
        assertThatExceptionOfType(UnexpectedProviderData.class).isThrownBy(() -> reference.toLocationCode());
    }

    @Test
    void toCountryCodeIso_null() {
        String countryCodeIso = TafTapLocationReference.toCountryCodeIso(null);
        assertThat(countryCodeIso).isNull();
    }

    @Test
    void toCountryCodeIso_unknown() {
        assertThatExceptionOfType(UnexpectedProviderData.class).isThrownBy(() -> TafTapLocationReference.toCountryCodeIso(69));

    }

    @Test
    void toCountryCodeIso_correct() {
        String countryCodeIso = TafTapLocationReference.toCountryCodeIso(85);
        assertThat(countryCodeIso).isEqualTo("CH");
    }
}
