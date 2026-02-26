package ch.sbb.backend.admin.domain.settings.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import org.junit.jupiter.api.Test;

class SemVersionTest {

    @Test
    void versionGreaterThan() {
        SemanticVersion smallerVersion = new SemanticVersion("1.0.1");
        SemanticVersion greaterVersion = new SemanticVersion("1.13.0");

        assertThat(smallerVersion.compareTo(greaterVersion)).isEqualTo(-1);
    }

    @Test
    void versionSmallerThan() {
        SemanticVersion smallerVersion = new SemanticVersion("0.3.123");
        SemanticVersion greaterVersion = new SemanticVersion("1.2.6");

        assertThat(greaterVersion.compareTo(smallerVersion)).isEqualTo(1);
    }

    @Test
    void versionEqual() {
        SemanticVersion smallerVersion = new SemanticVersion("2.1.0");
        SemanticVersion greaterVersion = new SemanticVersion("2.1.0");

        assertThat(greaterVersion).isEqualByComparingTo(smallerVersion);
    }

    @Test
    void versionWrongPattern() {
        assertThatExceptionOfType(IllegalArgumentException.class).isThrownBy(() -> new SemanticVersion("I'm invalid"));
    }
}
