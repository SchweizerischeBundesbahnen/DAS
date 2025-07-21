package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;

class TafTapLocationReferenceTest {

    @Test
    void asString_null() {
        TafTapLocationReference reference = new TafTapLocationReference(null, null);
        String result = reference.asString();
        assertNull(result);
    }

    @Test
    void asString_shouldFormatCountryAndUicCode() {
        TafTapLocationReference reference = new TafTapLocationReference(12, 345678);
        String result = reference.asString();
        assertEquals("12345678", result);
    }

    @Test
    void asString_shouldFormatCountryAndUicCodeWith0() {
        TafTapLocationReference reference = new TafTapLocationReference(5, 23);
        String result = reference.asString();
        assertEquals("05000023", result);
    }
}