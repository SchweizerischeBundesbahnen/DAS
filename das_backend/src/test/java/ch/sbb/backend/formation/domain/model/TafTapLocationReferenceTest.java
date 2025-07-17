package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class TafTapLocationReferenceTest {

    @Test
    void toString_null() {
        TafTapLocationReference reference = new TafTapLocationReference(null, null);
        String result = reference.toString();
        assertEquals("", result);
    }

    @Test
    void toString_shouldFormatCountryAndUicCode() {
        TafTapLocationReference reference = new TafTapLocationReference(12, 345678);
        String result = reference.toString();
        assertEquals("12345678", result);
    }

    @Test
    void toString_shouldFormatCountryAndUicCodeWith0() {
        TafTapLocationReference reference = new TafTapLocationReference(5, 23);
        String result = reference.toString();
        assertEquals("05000023", result);
    }
}