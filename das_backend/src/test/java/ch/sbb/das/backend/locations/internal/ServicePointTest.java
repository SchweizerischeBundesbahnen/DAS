package ch.sbb.das.backend.locations.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.locations.internal.ServicePoint.Content;
import ch.sbb.das.backend.locations.internal.ServicePoint.ServicePointNumber;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class ServicePointTest {

    private static final ServicePointNumber NUMBER = new ServicePointNumber(12345, 98);
    private static final ServicePointNumber OTHER_NUMBER = new ServicePointNumber(56789, 76);

    private static ServicePoint servicePoint(String designation, String abbreviation,
        ServicePointNumber number,
        LocalDate validFrom, LocalDate validTo) {
        return new ServicePoint(designation, abbreviation, validFrom, validTo, number);
    }

    @Test
    void contentShouldBeEqualForSameBusinessFieldsRegardlessOfValidity() {
        ServicePoint a = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));
        ServicePoint b = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 7, 1), LocalDate.of(2025, 12, 31));

        assertThat(a.content()).isEqualTo(b.content());
    }

    @Test
    void content_shouldDifferWhenDesignationDiffers() {
        Content bern = servicePoint("Bern", "BN", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();
        Content basel = servicePoint("Basel", "BN", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();

        assertThat(bern).isNotEqualTo(basel);
    }

    @Test
    void content_shouldDifferWhenAbbreviationDiffers() {
        Content bn = servicePoint("Bern", "BN", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();
        Content be = servicePoint("Bern", "BE", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();

        assertThat(bn).isNotEqualTo(be);
    }

    @Test
    void content_shouldDifferWhenServicePointNumberDiffers() {
        Content a = servicePoint("Bern", "BN", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();
        Content b = servicePoint("Bern", "BN", OTHER_NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();

        assertThat(a).isNotEqualTo(b);
    }

    @Test
    void shouldBeDirectlyFollowedByWhenNextStartsDayAfterCurrentEnds() {
        ServicePoint a = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));
        ServicePoint b = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 7, 1), LocalDate.of(2025, 12, 31));

        assertThat(a.isDirectlyFollowedBy(b)).isTrue();
    }

    @Test
    void shouldNotBeDirectlyFollowedByWhenGapExists() {
        ServicePoint a = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));
        ServicePoint b = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 7, 2), LocalDate.of(2025, 12, 31));

        assertThat(a.isDirectlyFollowedBy(b)).isFalse();
    }

    @Test
    void withValidTo_shouldNotBeDirectlyFollowedByWhenValidityPeriodsOverlap() {
        ServicePoint a = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));
        ServicePoint b = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 6, 30), LocalDate.of(2025, 12, 31));

        assertThat(a.isDirectlyFollowedBy(b)).isFalse();
    }

    @Test
    void withValidTo_shouldReturnCopyWithOnlyValidToChanged() {
        ServicePoint original = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));

        ServicePoint extended = original.withValidTo(LocalDate.of(2025, 12, 31));

        assertThat(extended.designationOfficial()).isEqualTo(original.designationOfficial());
        assertThat(extended.abbreviation()).isEqualTo(original.abbreviation());
        assertThat(extended.number()).isEqualTo(original.number());
        assertThat(extended.validFrom()).isEqualTo(original.validFrom());
        assertThat(extended.validTo()).isEqualTo(LocalDate.of(2025, 12, 31));
    }

    @Test
    void withValidTo_shouldNotMutateOriginal() {
        ServicePoint original = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));

        original.withValidTo(LocalDate.of(2025, 12, 31));

        assertThat(original.validTo()).isEqualTo(LocalDate.of(2025, 6, 30));
    }
}

