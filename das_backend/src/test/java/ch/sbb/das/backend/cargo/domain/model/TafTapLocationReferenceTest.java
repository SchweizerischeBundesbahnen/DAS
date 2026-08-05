package ch.sbb.das.backend.cargo.domain.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import ch.sbb.das.backend.locations.TafTapLocationReference;
import org.junit.jupiter.api.Test;

class TafTapLocationReferenceTest {

    @Test
    void of_string_shouldParseCountryAndPrimaryCode() {
        TafTapLocationReference reference = TafTapLocationReference.of("CH34567");
        assertThat(reference.countryCodeIso()).isEqualTo("CH");
        assertThat(reference.countryCodeUic()).isEqualTo(85);
        assertThat(reference.primaryCode()).isEqualTo(34567);
    }

    @Test
    void of_string_invalidCountry() {
        assertThatExceptionOfType(IllegalArgumentException.class)
            .isThrownBy(() -> TafTapLocationReference.of("XX12345"));
    }

    @Test
    void of_string_tooShort() {
        assertThatExceptionOfType(IllegalArgumentException.class)
            .isThrownBy(() -> TafTapLocationReference.of("CH"));
    }

    @Test
    void of_string_null() {
        assertThatExceptionOfType(IllegalArgumentException.class)
            .isThrownBy(() -> TafTapLocationReference.of((String) null));
    }

    @Test
    void of_uicCountryAndLocationCode() {
        TafTapLocationReference reference = TafTapLocationReference.of(85, 523440);
        assertThat(reference.countryCodeUic()).isEqualTo(85);
        assertThat(reference.primaryCode()).isEqualTo(52344);
        assertThat(reference.primaryCodeWithCheckDigit()).isEqualTo(523440);
    }

    @Test
    void of_fullUicCode() {
        TafTapLocationReference reference = TafTapLocationReference.of(85523440);
        assertThat(reference.countryCodeUic()).isEqualTo(85);
        assertThat(reference.countryCodeIso()).isEqualTo("CH");
        assertThat(reference.primaryCode()).isEqualTo(52344);
        assertThat(reference.primaryCodeWithCheckDigit()).isEqualTo(523440);
    }

    @Test
    void of_fullUicCode_roundtrip() {
        TafTapLocationReference reference = TafTapLocationReference.of(85523440);
        assertThat(reference.uicCode()).isEqualTo(85523440);
    }

    @Test
    void locationCode_shouldFormatCountryAndPrimaryCode() {
        TafTapLocationReference reference = TafTapLocationReference.of("CH34567");
        assertThat(reference.locationCode()).isEqualTo("CH34567");
    }

    @Test
    void locationCode_shouldPadWithZeros() {
        TafTapLocationReference reference = TafTapLocationReference.of("CH00023");
        assertThat(reference.locationCode()).isEqualTo("CH00023");
    }

    @Test
    void locationCode_shouldFormatOtherCountry() {
        TafTapLocationReference reference = TafTapLocationReference.of("DE75985");
        assertThat(reference.locationCode()).isEqualTo("DE75985");
    }

    @Test
    void locationCode_shouldThrowWithTooLongCode() {
        assertThatExceptionOfType(IllegalArgumentException.class)
            .isThrownBy(() -> TafTapLocationReference.of("CH25675673"));
    }

    @Test
    void locationCode_fromFullUicCode() {
        TafTapLocationReference reference = TafTapLocationReference.of(85523440);
        assertThat(reference.locationCode()).isEqualTo("CH52344");
    }

    @Test
    void primaryCodeWithCheckDigit_throwsWhenCheckDigitNotAvailable() {
        TafTapLocationReference reference = TafTapLocationReference.of("CH52344");
        assertThatExceptionOfType(IllegalStateException.class)
            .isThrownBy(reference::primaryCodeWithCheckDigit);
    }

    @Test
    void constructor_withCheckDigit() {
        TafTapLocationReference reference = new TafTapLocationReference(85, 52344, 0);
        assertThat(reference.countryCodeIso()).isEqualTo("CH");
        assertThat(reference.primaryCode()).isEqualTo(52344);
        assertThat(reference.primaryCodeWithCheckDigit()).isEqualTo(523440);
        assertThat(reference.uicCode()).isEqualTo(85523440);
    }

    @Test
    void constructor_withoutCheckDigit() {
        TafTapLocationReference reference = new TafTapLocationReference(85, 7000, null);
        assertThat(reference.countryCodeIso()).isEqualTo("CH");
        assertThat(reference.primaryCode()).isEqualTo(7000);
        assertThat(reference.locationCode()).isEqualTo("CH07000");
    }

    @Test
    void constructor_unknownCountryCode() {
        assertThatExceptionOfType(IllegalArgumentException.class)
            .isThrownBy(() -> new TafTapLocationReference(69, 12345, null));
    }

    @Test
    void equals_sameLocation_withAndWithoutCheckDigit() {
        TafTapLocationReference fromString = TafTapLocationReference.of("CH52344");
        TafTapLocationReference fromUic = TafTapLocationReference.of(85, 523441);
        assertThat(fromString)
            .isEqualTo(fromUic)
            .hasSameHashCodeAs(fromUic);
    }

    @Test
    void equals_differentLocation() {
        TafTapLocationReference a = TafTapLocationReference.of("CH52344");
        TafTapLocationReference b = TafTapLocationReference.of("CH12345");
        assertThat(a).isNotEqualTo(b);
    }

    @Test
    void equals_differentCountry() {
        TafTapLocationReference a = TafTapLocationReference.of("CH52344");
        TafTapLocationReference b = TafTapLocationReference.of("DE52344");
        assertThat(a).isNotEqualTo(b);
    }

    @Test
    void toString_returnsLocationCode() {
        TafTapLocationReference reference = TafTapLocationReference.of("CH52344");
        assertThat(reference.toString()).hasToString("CH52344");
    }
}
