package ch.sbb.das.backend.locations.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.locations.internal.ServicePoint.Content;
import ch.sbb.das.backend.locations.internal.ServicePoint.ServicePointNumber;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;

class ServicePointTest {

    private static final ServicePointNumber NUMBER = new ServicePointNumber(98, 12345, 0);
    private static final ServicePointNumber OTHER_NUMBER = new ServicePointNumber(76, 56789, 0);

    private static ServicePoint servicePoint(String designation, String abbreviation,
        ServicePointNumber number,
        LocalDate validFrom, LocalDate validTo) {
        return new ServicePoint(designation, abbreviation, validFrom, validTo, number, null, List.of("TRAIN"));
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
    void contentShouldDifferWhenDesignationDiffers() {
        Content bern = servicePoint("Bern", "BN", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();
        Content basel = servicePoint("Basel", "BN", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();

        assertThat(bern).isNotEqualTo(basel);
    }

    @Test
    void contentShouldDifferWhenAbbreviationDiffers() {
        Content bn = servicePoint("Bern", "BN", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();
        Content be = servicePoint("Bern", "BE", NUMBER, DateTimeUtil.today(), DateTimeUtil.today()).content();

        assertThat(bn).isNotEqualTo(be);
    }

    @Test
    void contentShouldDifferWhenServicePointNumberDiffers() {
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
    void shouldNotBeDirectlyFollowedByWhenValidityPeriodsOverlap() {
        ServicePoint a = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));
        ServicePoint b = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 6, 30), LocalDate.of(2025, 12, 31));

        assertThat(a.isDirectlyFollowedBy(b)).isFalse();
    }

    @Test
    void withValidToShouldReturnCopyWithOnlyValidToChanged() {
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
    void withValidToShouldNotMutateOriginal() {
        ServicePoint original = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));

        original.withValidTo(LocalDate.of(2025, 12, 31));

        assertThat(original.validTo()).isEqualTo(LocalDate.of(2025, 6, 30));
    }

    private static ServicePoint relevantServicePoint(String abbreviation, String technicalTimetableType, List<String> meansOfTransport) {
        return new ServicePoint("Bern", abbreviation, DateTimeUtil.today(), DateTimeUtil.today(), NUMBER, technicalTimetableType, meansOfTransport);
    }

    @Test
    void shouldBeRelevantWhenAbbreviationPresentTypeNullAndMeansOfTransportEmpty() {
        ServicePoint sp = relevantServicePoint("BN", null, List.of());

        assertThat(sp.isRelevant()).isTrue();
    }

    @Test
    void shouldBeRelevantWhenMeansOfTransportIsNull() {
        ServicePoint sp = relevantServicePoint("BN", "SERVICE_STATION", null);

        assertThat(sp.isRelevant()).isTrue();
    }

    @Test
    void shouldBeRelevantWhenMeansOfTransportContainsOnlyTrain() {
        ServicePoint sp = relevantServicePoint("BN", "BRANCH", List.of("TRAIN", "TRAIN"));

        assertThat(sp.isRelevant()).isTrue();
    }

    @Test
    void shouldBeRelevantForEachAllowedTechnicalTimetableType() {
        assertThat(relevantServicePoint("BN", "COUNTRY_BORDER", null).isRelevant()).isTrue();
        assertThat(relevantServicePoint("BN", "BRANCH", null).isRelevant()).isTrue();
        assertThat(relevantServicePoint("BN", "SERVICE_STATION", null).isRelevant()).isTrue();
        assertThat(relevantServicePoint("BN", "EX_STOP_POINT", null).isRelevant()).isTrue();
    }

    @Test
    void shouldNotBeRelevantWhenAbbreviationIsNull() {
        ServicePoint sp = relevantServicePoint(null, null, List.of("TRAIN"));

        assertThat(sp.isRelevant()).isFalse();
    }

    @Test
    void shouldNotBeRelevantWhenAbbreviationIsBlank() {
        ServicePoint sp = relevantServicePoint("  ", null, List.of("TRAIN"));

        assertThat(sp.isRelevant()).isFalse();
    }

    @Test
    void shouldNotBeRelevantWhenTechnicalTimetableTypeIsNotAllowed() {
        ServicePoint sp = relevantServicePoint("BN", "LANE_CHANGE", List.of("TRAIN"));

        assertThat(sp.isRelevant()).isFalse();
    }

    @Test
    void shouldNotBeRelevantWhenTechnicalTimetableTypeIsUnknown() {
        ServicePoint sp = relevantServicePoint("BN", "UNKNOWN", List.of("TRAIN"));

        assertThat(sp.isRelevant()).isFalse();
    }

    @Test
    void shouldNotBeRelevantWhenMeansOfTransportContainsNonTrain() {
        ServicePoint sp = relevantServicePoint("BN", "BRANCH", List.of("TRAIN", "BUS"));

        assertThat(sp.isRelevant()).isFalse();
    }
}

