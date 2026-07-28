package ch.sbb.das.backend.locations.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.locations.internal.ServicePoint.ServicePointNumber;
import java.time.LocalDate;
import java.util.List;
import org.assertj.core.groups.Tuple;
import org.junit.jupiter.api.Test;

class TafTapLocationsImportServiceTest {

    private static final ServicePointNumber NUMBER = new ServicePointNumber(12345, 98);
    private static final ServicePointNumber OTHER_NUMBER = new ServicePointNumber(56789, 76);

    private final TafTapLocationsImportService service =
        new TafTapLocationsImportService(null, null, null);

    private static ServicePoint servicePoint(String designation, String abbreviation,
        ServicePointNumber number,
        LocalDate validFrom, LocalDate validTo) {
        return new ServicePoint(designation, abbreviation, validFrom, validTo, number);
    }

    @Test
    void shouldCollapseChainOfAdjacentDuplicatesIntoOne() {
        ServicePoint a = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 3, 31));
        ServicePoint b = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 4, 1), LocalDate.of(2025, 6, 30));
        ServicePoint c = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 7, 1), LocalDate.of(2025, 12, 31));

        List<ServicePoint> result = service.mergeAdjacentDuplicates(List.of(a, b, c));

        assertThat(result).hasSize(1);
        assertThat(result.getFirst().validFrom()).isEqualTo(LocalDate.of(2025, 1, 1));
        assertThat(result.getFirst().validTo()).isEqualTo(LocalDate.of(2025, 12, 31));
    }

    @Test
    void shouldMergePerContentGroupIndependently() {
        ServicePoint bern1 = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));
        ServicePoint bern2 = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 7, 1), LocalDate.of(2025, 12, 31));
        ServicePoint bern3 = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2026, 3, 1), LocalDate.of(2026, 12, 31)); // gap → separate
        ServicePoint basel = servicePoint("Basel", "BS", OTHER_NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 12, 31));

        List<ServicePoint> result =
            service.mergeAdjacentDuplicates(List.of(bern1, bern2, bern3, basel));

        assertThat(result)
            .extracting(ServicePoint::designationOfficial,
                ServicePoint::validFrom,
                ServicePoint::validTo)
            .containsExactlyInAnyOrder(
                Tuple.tuple("Bern", LocalDate.of(2025, 1, 1), LocalDate.of(2025, 12, 31)),
                Tuple.tuple("Bern", LocalDate.of(2026, 3, 1), LocalDate.of(2026, 12, 31)),
                Tuple.tuple("Basel", LocalDate.of(2025, 1, 1), LocalDate.of(2025, 12, 31))
            );
    }

    @Test
    void shouldMergeCorrectlyWhenInputIsUnordered() {
        ServicePoint later = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 7, 1), LocalDate.of(2025, 12, 31));
        ServicePoint earlier = servicePoint("Bern", "BN", NUMBER,
            LocalDate.of(2025, 1, 1), LocalDate.of(2025, 6, 30));

        List<ServicePoint> result = service.mergeAdjacentDuplicates(List.of(later, earlier));

        assertThat(result).hasSize(1);
        assertThat(result.getFirst().validFrom()).isEqualTo(LocalDate.of(2025, 1, 1));
        assertThat(result.getFirst().validTo()).isEqualTo(LocalDate.of(2025, 12, 31));
    }

    @Test
    void shouldReturnEmptyListForEmptyInput() {
        assertThat(service.mergeAdjacentDuplicates(List.of())).isEmpty();
    }
}
