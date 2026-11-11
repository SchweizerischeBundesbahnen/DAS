package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.IndexedSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.KnownSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.ZipStatistics;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

@IntegrationTest
class PreloadedSegmentProfileRepositoryIntegrationTest {

    private static final OffsetDateTime NOW = OffsetDateTime.of(2026, 11, 11, 10, 30, 0, 0, ZoneOffset.UTC);
    private static final OffsetDateTime CUTOFF = NOW.minusDays(30);

    @Autowired
    private PreloadedSegmentProfileRepository underTest;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    @AfterEach
    void deleteSegmentProfiles() {
        jdbcTemplate.update("DELETE FROM preloaded_segment_profile");
    }

    @DisplayName("findAllBySpIdVersionIn_returnsTheKnownRowsWithTheirLocalRegulationLinks|p7Kq2mXb9LwVcRt3Ynz0|tests:2657")
    @Test
    void findAllBySpIdVersionIn_returnsTheKnownRowsWithTheirLocalRegulationLinks() {
        underTest.saveAll(List.of(
            row("SP_1_1_0", "Segments_1.zip", NOW, List.of("LR_1_DE_0", "LR_1_FR_0")),
            row("SP_2_1_0", null, NOW, List.of())));

        List<KnownSegmentProfile> known = underTest.findAllBySpIdVersionIn(Set.of("SP_1_1_0", "SP_2_1_0", "SP_3_1_0"));

        assertThat(known).extracting(KnownSegmentProfile::getSpIdVersion).containsExactlyInAnyOrder("SP_1_1_0", "SP_2_1_0");
        assertThat(known).filteredOn(k -> k.getSpIdVersion().equals("SP_1_1_0")).singleElement()
            .satisfies(k -> assertThat(k.getRelatedLrSpIdVersions()).containsExactly("LR_1_DE_0", "LR_1_FR_0"));
        assertThat(known).filteredOn(k -> k.getSpIdVersion().equals("SP_2_1_0")).singleElement()
            .satisfies(k -> assertThat(k.getRelatedLrSpIdVersions()).isEmpty());
    }

    @DisplayName("zipStatistics_countsTheEntriesAndTheStaleEntriesOfEveryZip|Vt4nLs8dQe1xMzPa6Hc2|tests:2657")
    @Test
    void zipStatistics_countsTheEntriesAndTheStaleEntriesOfEveryZip() {
        underTest.saveAll(List.of(
            row("A_1_0", "Segments_1.zip", NOW, List.of()),
            row("B_1_0", "Segments_1.zip", CUTOFF.minusSeconds(1), List.of()),
            row("C_1_0", "Segments_1.zip", CUTOFF, List.of()),
            row("D_1_0", "Segments_2026-11-11T10-00-00Z.zip", NOW, List.of()),
            row("E_1_0", null, NOW, List.of())));

        List<ZipStatistics> statistics = underTest.zipStatistics(CUTOFF);

        assertThat(statistics).extracting(ZipStatistics::getZipKey, ZipStatistics::getEntries, ZipStatistics::getStaleEntries)
            .containsExactlyInAnyOrder(
                org.assertj.core.groups.Tuple.tuple("Segments_1.zip", 3L, 1L),
                org.assertj.core.groups.Tuple.tuple("Segments_2026-11-11T10-00-00Z.zip", 1L, 0L));
        assertThat(underTest.findDistinctZipKeys()).containsExactlyInAnyOrder("Segments_1.zip", "Segments_2026-11-11T10-00-00Z.zip");
    }

    @DisplayName("assignZipKey_publishesThePendingRowsAndDropsTheirXml|Rz9wHk3uJb7yNq0eTf5L|tests:2657")
    @Test
    void assignZipKey_publishesThePendingRowsAndDropsTheirXml() {
        underTest.saveAll(List.of(pending("P1_1_0"), pending("P2_1_0"), pending("P3_1_0")));
        assertThat(underTest.findAllByZipKeyIsNullOrderByIdAsc()).extracting(PreloadedSegmentProfileEntity::getSpIdVersion).containsExactly("P1_1_0", "P2_1_0", "P3_1_0");

        underTest.assignZipKey("Segments_2026-11-11T10-00-00Z.zip", List.of("P1_1_0", "P2_1_0"));

        assertThat(underTest.findAllByZipKeyIsNullOrderByIdAsc()).extracting(PreloadedSegmentProfileEntity::getSpIdVersion).containsExactly("P3_1_0");
        List<IndexedSegmentProfile> published = underTest.findAllByZipKeyIn(List.of("Segments_2026-11-11T10-00-00Z.zip"));
        assertThat(published).extracting(IndexedSegmentProfile::getSpIdVersion).containsExactlyInAnyOrder("P1_1_0", "P2_1_0");
        assertThat(published).allSatisfy(row -> assertThat(row.getLastSeen()).isEqualTo(NOW));
        assertThat(jdbcTemplate.queryForList("SELECT pending_xml FROM preloaded_segment_profile WHERE zip_key IS NOT NULL", String.class)).containsOnlyNulls();
    }

    @DisplayName("deleteAllByZipKeyIn_removesTheRowsOfThoseZipsOnly|Gm2cXv6sWn4kBd8pLq1A|tests:2657")
    @Test
    void deleteAllByZipKeyIn_removesTheRowsOfThoseZipsOnly() {
        underTest.saveAll(List.of(
            row("A_1_0", "Segments_1.zip", NOW, List.of()),
            row("B_1_0", "Segments_2.zip", NOW, List.of()),
            row("C_1_0", "Segments_3.zip", NOW, List.of()),
            pending("P1_1_0")));

        underTest.deleteAllByZipKeyIn(List.of("Segments_1.zip", "Segments_2.zip"));

        assertThat(underTest.findAll()).extracting(PreloadedSegmentProfileEntity::getSpIdVersion).containsExactlyInAnyOrder("C_1_0", "P1_1_0");
    }

    private static PreloadedSegmentProfileEntity row(String spIdVersion, String zipKey, OffsetDateTime lastSeen, List<String> relatedLrSpIdVersions) {
        return PreloadedSegmentProfileEntity.builder().spIdVersion(spIdVersion).zipKey(zipKey).lastSeen(lastSeen).relatedLrSpIdVersions(relatedLrSpIdVersions).build();
    }

    private static PreloadedSegmentProfileEntity pending(String spIdVersion) {
        return PreloadedSegmentProfileEntity.builder().spIdVersion(spIdVersion).lastSeen(NOW).pendingXml("<SegmentProfile/>").build();
    }
}
