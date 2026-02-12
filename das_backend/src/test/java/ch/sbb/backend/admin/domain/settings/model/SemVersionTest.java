package ch.sbb.backend.admin.domain.settings.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import org.junit.jupiter.api.Test;

class SemVersionTest {

    @Test
    void versionGreaterThan() {
        SemVersion smallerVersion = new SemVersion("1.0.1");
        SemVersion greaterVersion = new SemVersion("1.13.0");

        assertThat(smallerVersion.compareTo(greaterVersion)).isEqualTo(-1);
    }

    @Test
    void versionSmallerThan() {
        SemVersion smallerVersion = new SemVersion("0.3.123");
        SemVersion greaterVersion = new SemVersion("1.2.6");

        assertThat(greaterVersion.compareTo(smallerVersion)).isEqualTo(1);
    }

    @Test
    void versionEqual() {
        SemVersion smallerVersion = new SemVersion("2.1.0");
        SemVersion greaterVersion = new SemVersion("2.1.0");

        assertThat(greaterVersion).isEqualByComparingTo(smallerVersion);
    }

    @Test
    void versionWrongPattern() {
        assertThatExceptionOfType(IllegalArgumentException.class).isThrownBy(() -> new SemVersion("I'm invalid"));
    }
}
