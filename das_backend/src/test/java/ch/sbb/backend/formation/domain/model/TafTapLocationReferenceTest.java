package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;

class TafTapLocationReferenceTest {

    @Test
    void toLocationCode_null() {
        TafTapLocationReference reference = new TafTapLocationReference(null, null);
        String result = reference.toLocationCode();
        assertNull(result);
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCode() {
        TafTapLocationReference reference = new TafTapLocationReference(12, 345678);
        String result = reference.toLocationCode();
        assertEquals("12345678", result);
    }

    @Test
    void toLocationCode_shouldFormatCountryAndUicCodeWith0() {
        TafTapLocationReference reference = new TafTapLocationReference(5, 23);
        String result = reference.toLocationCode();
        assertEquals("05000023", result);
    }
}