package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.IndexedSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.KnownSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.ZipStatistics;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration.SegmentProfileStoreProperties;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.NSPListComplexType;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.NetworkSpecificParameter;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPAreas;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPZone;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TAFTAPLocation;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Base64;
import java.util.Optional;
import java.util.Random;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.projection.ProjectionFactory;
import org.springframework.data.projection.SpelAwareProxyProjectionFactory;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.util.unit.DataSize;

@ExtendWith(MockitoExtension.class)
class SegmentProfileStoreTest {

    private static final Instant NOW = Instant.parse("2026-11-11T10:30:00Z");
    private static final OffsetDateTime NOW_UTC = NOW.atOffset(ZoneOffset.UTC);
    private static final OffsetDateTime LONG_AGO = NOW_UTC.minusDays(40);
    private static final String OPEN_ZIP = "Segments_2026-11-11T10-00-00Z.zip";
    private static final String FROZEN_HOURLY_ZIP = "Segments_2026-11-11T08-00-00Z.zip";
    private static final String LEGACY_ZIP = "Segments_7.zip";
    private static final String PACKED_ZIP = "Segments_2026-11-11T10-20-00Z-packed.zip";
    private static final String NEW_HOURLY_ZIP = "Segments_2026-11-11T10-30-00Z.zip";
    private static final String NEW_PACKED_ZIP = "Segments_2026-11-11T10-30-00Z-packed.zip";

    private final ProjectionFactory projections = new SpelAwareProxyProjectionFactory();

    @Mock
    private XmlHelper xmlHelper;

    @Mock
    private S3Service s3Service;

    @Mock
    private PreloadedSegmentProfileRepository repository;

    @Mock
    private PlatformTransactionManager transactionManager;

    @Captor
    private ArgumentCaptor<List<PreloadedSegmentProfileEntity>> savedEntities;

    @Captor
    private ArgumentCaptor<byte[]> uploadedBytes;

    private SegmentProfileStore underTest;

    @BeforeEach
    void setUp() {
        underTest = storeWithZipMaxBytes(DataSize.ofMegabytes(5));
    }

    private SegmentProfileStore storeWithZipMaxBytes(DataSize zipMaxBytes) {
        SegmentProfileStoreProperties properties = new SegmentProfileStoreProperties(Duration.ofDays(30), 0.5, Duration.ofHours(1), Duration.ofHours(24), zipMaxBytes);
        return new SegmentProfileStore(xmlHelper, s3Service, repository, transactionManager, Clock.fixed(NOW, ZoneOffset.UTC), properties);
    }

    @Test
    void missing_returnsTheReferencedSpsTheStoreDoesNotHoldAndKeepsTheKnownOnesAndTheirLocalRegulationSpsAlive() {
        SegmentProfileIdentification known = spId("SP_1");
        SegmentProfileIdentification unknown = spId("SP_2");
        when(repository.findAllBySpIdVersionIn(Set.of("SP_1_1_0", "SP_2_1_0"))).thenReturn(List.of(known("SP_1_1_0", List.of("LR_1_DE_0", "LR_1_FR_0"))));

        Set<SegmentProfileIdentification> missing = underTest.missing(Set.of(known, unknown));

        assertThat(missing).containsExactly(unknown);
        verify(repository).updateLastSeenBySpIdVersion(NOW_UTC, Set.of("SP_1_1_0", "LR_1_DE_0", "LR_1_FR_0"));
    }

    @Test
    void missing_whenNothingIsReferenced_returnsNothingWithoutTouchingTheIndex() {
        assertThat(underTest.missing(Set.of())).isEmpty();

        verifyNoInteractions(repository);
    }

    @Test
    void add_keepsNewSegmentProfilesPendingWithTheirXmlAndLocalRegulationLinks() {
        givenXml();
        when(repository.findAllBySpIdVersionIn(Set.of("SP-1_1_0"))).thenReturn(List.of());

        underTest.add(List.of(createSpWithLocalRegulations("SP-1", "LR_1;LR_2")));

        verify(repository).saveAll(savedEntities.capture());
        assertThat(savedEntities.getValue()).singleElement().satisfies(e -> {
            assertThat(e.getSpIdVersion()).isEqualTo("SP-1_1_0");
            assertThat(e.getZipKey()).isNull();
            assertThat(e.getPendingXml()).isEqualTo("<SegmentProfile id='SP-1'/>");
            assertThat(e.getLastSeen()).isEqualTo(NOW_UTC);
            assertThat(e.getRelatedLrSpIdVersions()).containsExactly("LR_1_DE_0", "LR_1_FR_0", "LR_1_IT_0", "LR_2_DE_0", "LR_2_FR_0", "LR_2_IT_0");
        });
    }

    @Test
    void add_skipsSegmentProfilesTheIndexAlreadyKnowsAndDuplicatesWithinTheBatch() {
        givenXml();
        when(repository.findAllBySpIdVersionIn(Set.of("SP-1_1_0", "SP-2_1_0"))).thenReturn(List.of(known("SP-1_1_0", List.of())));

        underTest.add(List.of(createSp("SP-1"), createSp("SP-2"), createSp("SP-2")));

        verify(repository).saveAll(savedEntities.capture());
        assertThat(savedEntities.getValue()).extracting(PreloadedSegmentProfileEntity::getSpIdVersion).containsExactly("SP-2_1_0");
    }

    @Test
    void add_whenEverySegmentProfileIsKnown_insertsNothing() {
        when(repository.findAllBySpIdVersionIn(Set.of("SP-1_1_0"))).thenReturn(List.of(known("SP-1_1_0", List.of())));

        underTest.add(List.of(createSp("SP-1")));

        verify(repository, never()).saveAll(anyCollection());
    }

    @Test
    void publish_whenNothingIsPending_uploadsNothing() {
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenReturn(List.of());

        assertThat(underTest.publish()).isZero();

        verifyNoInteractions(s3Service);
        verify(repository, never()).assignZipKey(anyString(), anyCollection());
    }

    @Test
    void publish_appendsThePendingEntriesToTheOpenZipAndAssignsItsKeyAfterTheUpload() throws Exception {
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenReturn(List.of(pending("P1_1_0"), pending("P2_1_0")));
        when(repository.findDistinctZipKeys()).thenReturn(List.of(LEGACY_ZIP, FROZEN_HOURLY_ZIP, OPEN_ZIP, PACKED_ZIP));
        when(s3Service.downloadZip(OPEN_ZIP)).thenReturn(Optional.of(zipOf(Map.of("sp/SP_OLD_1_0.xml", "<old/>"))));

        int published = underTest.publish();

        assertThat(published).isEqualTo(2);
        InOrder inOrder = inOrder(s3Service, repository);
        inOrder.verify(s3Service).uploadZip(eq(OPEN_ZIP), uploadedBytes.capture());
        inOrder.verify(repository).assignZipKey(OPEN_ZIP, List.of("P1_1_0", "P2_1_0"));
        assertThat(entriesOf(uploadedBytes.getValue())).containsExactly(
            Map.entry("sp/SP_OLD_1_0.xml", "<old/>"),
            Map.entry("sp/SP_P1_1_0.xml", "<pending P1_1_0/>"),
            Map.entry("sp/SP_P2_1_0.xml", "<pending P2_1_0/>"));
    }

    @Test
    void publish_whenTheNewestHourlyZipIsOlderThanTheMaxAge_opensANewZipNamedAfterNowWithoutDownloadingAnything() throws Exception {
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenReturn(List.of(pending("P1_1_0")));
        when(repository.findDistinctZipKeys()).thenReturn(List.of(LEGACY_ZIP, FROZEN_HOURLY_ZIP, PACKED_ZIP));

        underTest.publish();

        verify(s3Service, never()).downloadZip(anyString());
        verify(s3Service).uploadZip(eq(NEW_HOURLY_ZIP), uploadedBytes.capture());
        assertThat(entriesOf(uploadedBytes.getValue())).containsExactly(Map.entry("sp/SP_P1_1_0.xml", "<pending P1_1_0/>"));
        verify(repository).assignZipKey(NEW_HOURLY_ZIP, List.of("P1_1_0"));
    }

    @Test
    void publish_skipsAPendingEntryTheOpenZipAlreadyHoldsFromAnInterruptedPublish() throws Exception {
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenReturn(List.of(pending("P1_1_0"), pending("P2_1_0")));
        when(repository.findDistinctZipKeys()).thenReturn(List.of(OPEN_ZIP));
        when(s3Service.downloadZip(OPEN_ZIP)).thenReturn(Optional.of(zipOf(Map.of("sp/SP_P1_1_0.xml", "<pending P1_1_0/>"))));

        underTest.publish();

        verify(s3Service).uploadZip(eq(OPEN_ZIP), uploadedBytes.capture());
        assertThat(entriesOf(uploadedBytes.getValue())).containsExactly(
            Map.entry("sp/SP_P1_1_0.xml", "<pending P1_1_0/>"),
            Map.entry("sp/SP_P2_1_0.xml", "<pending P2_1_0/>"));
        verify(repository).assignZipKey(OPEN_ZIP, List.of("P1_1_0", "P2_1_0"));
    }

    @Test
    void publish_whenTheOpenZipIsMissingFromTheBucket_writesItAgainWithThePendingEntries() throws Exception {
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenReturn(List.of(pending("P1_1_0")));
        when(repository.findDistinctZipKeys()).thenReturn(List.of(OPEN_ZIP));
        when(s3Service.downloadZip(OPEN_ZIP)).thenReturn(Optional.empty());

        underTest.publish();

        verify(s3Service).uploadZip(eq(OPEN_ZIP), uploadedBytes.capture());
        assertThat(entriesOf(uploadedBytes.getValue())).containsExactly(Map.entry("sp/SP_P1_1_0.xml", "<pending P1_1_0/>"));
    }

    @Test
    void publish_closesTheZipOnceItReachedTheSizeCapAndContinuesInTheNextOne() throws Exception {
        underTest = storeWithZipMaxBytes(DataSize.ofBytes(450));
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenReturn(List.of(bulkyPending("P1_1_0"), bulkyPending("P2_1_0"), bulkyPending("P3_1_0")));
        when(repository.findDistinctZipKeys()).thenReturn(List.of());

        int published = underTest.publish();

        assertThat(published).isEqualTo(3);
        ArgumentCaptor<String> keys = ArgumentCaptor.forClass(String.class);
        verify(s3Service, org.mockito.Mockito.times(2)).uploadZip(keys.capture(), uploadedBytes.capture());
        assertThat(keys.getAllValues()).containsExactly(NEW_HOURLY_ZIP, "Segments_2026-11-11T10-30-01Z.zip");
        assertThat(entriesOf(uploadedBytes.getAllValues().get(0)).keySet()).containsExactly("sp/SP_P1_1_0.xml", "sp/SP_P2_1_0.xml");
        assertThat(entriesOf(uploadedBytes.getAllValues().get(1)).keySet()).containsExactly("sp/SP_P3_1_0.xml");
        verify(repository).assignZipKey(NEW_HOURLY_ZIP, List.of("P1_1_0", "P2_1_0"));
        verify(repository).assignZipKey("Segments_2026-11-11T10-30-01Z.zip", List.of("P3_1_0"));
    }

    @Test
    void publish_whenTheOpenZipAlreadyReachedTheSizeCap_rollsToANewZipWithoutAppendingToIt() throws Exception {
        underTest = storeWithZipMaxBytes(DataSize.ofBytes(100));
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenReturn(List.of(pending("P1_1_0")));
        when(repository.findDistinctZipKeys()).thenReturn(List.of(OPEN_ZIP));
        when(s3Service.downloadZip(OPEN_ZIP)).thenReturn(Optional.of(zipOf(Map.of("sp/SP_OLD_1_0.xml", "<old/>"))));

        underTest.publish();

        verify(s3Service, never()).uploadZip(eq(OPEN_ZIP), any());
        verify(s3Service).uploadZip(eq(NEW_HOURLY_ZIP), uploadedBytes.capture());
        assertThat(entriesOf(uploadedBytes.getValue())).containsExactly(Map.entry("sp/SP_P1_1_0.xml", "<pending P1_1_0/>"));
        verify(repository).assignZipKey(NEW_HOURLY_ZIP, List.of("P1_1_0"));
    }

    @Test
    void compact_splitsThePackedZipOnceItReachedTheSizeCap() throws Exception {
        underTest = storeWithZipMaxBytes(DataSize.ofBytes(450));
        String oldHourlyZip = "Segments_2026-11-10T08-00-00Z.zip";
        when(repository.zipStatistics(any())).thenReturn(List.of(statistics(oldHourlyZip, 4, 1)));
        when(repository.findAllByZipKeyIn(List.of(oldHourlyZip))).thenReturn(List.of(
            indexed("A_1_0", oldHourlyZip, NOW_UTC), indexed("B_1_0", oldHourlyZip, NOW_UTC), indexed("C_1_0", oldHourlyZip, NOW_UTC), indexed("D_1_0", oldHourlyZip, LONG_AGO)));
        when(s3Service.downloadZip(oldHourlyZip)).thenReturn(Optional.of(zipOf(
            Map.of("sp/SP_A_1_0.xml", bulkyXml("A"), "sp/SP_B_1_0.xml", bulkyXml("B"), "sp/SP_C_1_0.xml", bulkyXml("C"), "sp/SP_D_1_0.xml", bulkyXml("D")))));

        underTest.compact();

        ArgumentCaptor<String> keys = ArgumentCaptor.forClass(String.class);
        verify(s3Service, org.mockito.Mockito.times(2)).uploadZip(keys.capture(), uploadedBytes.capture());
        assertThat(keys.getAllValues()).containsExactly(NEW_PACKED_ZIP, "Segments_2026-11-11T10-30-01Z-packed.zip");
        assertThat(entriesOf(uploadedBytes.getAllValues().get(0)).keySet()).containsExactly("sp/SP_A_1_0.xml", "sp/SP_B_1_0.xml");
        assertThat(entriesOf(uploadedBytes.getAllValues().get(1)).keySet()).containsExactly("sp/SP_C_1_0.xml");
        verify(repository).assignZipKey(NEW_PACKED_ZIP, List.of("A_1_0", "B_1_0"));
        verify(repository).assignZipKey("Segments_2026-11-11T10-30-01Z-packed.zip", List.of("C_1_0"));
        verify(repository).deleteAllByZipKeyIn(List.of(oldHourlyZip));
        verify(s3Service).deleteObjects(List.of(oldHourlyZip));
    }

    @Test
    void compact_rebuildsAFrozenZipOverTheStaleShareIntoAPackedZipWithItsLiveEntriesOnly() throws Exception {
        when(repository.zipStatistics(LONG_AGO.plusDays(10))).thenReturn(List.of(statistics(LEGACY_ZIP, 4, 3), statistics(OPEN_ZIP, 10, 0)));
        when(repository.findAllByZipKeyIn(List.of(LEGACY_ZIP))).thenReturn(List.of(
            indexed("A_1_0", LEGACY_ZIP, NOW_UTC.minusDays(1)),
            indexed("B_1_0", LEGACY_ZIP, LONG_AGO), indexed("C_1_0", LEGACY_ZIP, LONG_AGO), indexed("D_1_0", LEGACY_ZIP, LONG_AGO)));
        when(s3Service.downloadZip(LEGACY_ZIP)).thenReturn(Optional.of(zipOf(
            Map.of("sp/SP_A_1_0.xml", "<a/>", "sp/SP_B_1_0.xml", "<b/>", "sp/SP_C_1_0.xml", "<c/>", "sp/SP_D_1_0.xml", "<d/>", "sp/SP_ORPHAN_1_0.xml", "<orphan/>"))));

        underTest.compact();

        InOrder inOrder = inOrder(s3Service, repository);
        inOrder.verify(s3Service).uploadZip(eq(NEW_PACKED_ZIP), uploadedBytes.capture());
        inOrder.verify(repository).assignZipKey(NEW_PACKED_ZIP, List.of("A_1_0"));
        inOrder.verify(repository).deleteAllByZipKeyIn(List.of(LEGACY_ZIP));
        inOrder.verify(s3Service).deleteObjects(List.of(LEGACY_ZIP));
        assertThat(entriesOf(uploadedBytes.getValue())).containsExactly(Map.entry("sp/SP_A_1_0.xml", "<a/>"));
        verify(s3Service, never()).downloadZip(OPEN_ZIP);
    }

    @Test
    void compact_packsTheFrozenHourlyZipsOlderThanThePackAgeIntoOnePackedZip() throws Exception {
        String yesterdayMorning = "Segments_2026-11-10T08-00-00Z.zip";
        String yesterdayNoon = "Segments_2026-11-10T10-00-00Z.zip";
        String oldPackedZip = "Segments_2026-11-09T10-00-00Z-packed.zip";
        when(repository.zipStatistics(any())).thenReturn(List.of(
            statistics(yesterdayNoon, 1, 0), statistics(yesterdayMorning, 2, 0), statistics(FROZEN_HOURLY_ZIP, 1, 0), statistics(oldPackedZip, 5, 0), statistics(OPEN_ZIP, 1, 0)));
        when(repository.findAllByZipKeyIn(List.of(yesterdayMorning, yesterdayNoon))).thenReturn(List.of(
            indexed("A_1_0", yesterdayMorning, NOW_UTC), indexed("B_1_0", yesterdayMorning, NOW_UTC), indexed("C_1_0", yesterdayNoon, NOW_UTC)));
        when(s3Service.downloadZip(yesterdayMorning)).thenReturn(Optional.of(zipOf(Map.of("sp/SP_A_1_0.xml", "<a/>", "sp/SP_B_1_0.xml", "<b/>"))));
        when(s3Service.downloadZip(yesterdayNoon)).thenReturn(Optional.of(zipOf(Map.of("sp/SP_C_1_0.xml", "<c/>"))));

        underTest.compact();

        verify(s3Service).uploadZip(eq(NEW_PACKED_ZIP), uploadedBytes.capture());
        assertThat(entriesOf(uploadedBytes.getValue())).containsExactlyInAnyOrderEntriesOf(Map.of("sp/SP_A_1_0.xml", "<a/>", "sp/SP_B_1_0.xml", "<b/>", "sp/SP_C_1_0.xml", "<c/>"));
        verify(repository).assignZipKey(eq(NEW_PACKED_ZIP), argThatContainsExactlyInAnyOrder("A_1_0", "B_1_0", "C_1_0"));
        verify(repository).deleteAllByZipKeyIn(List.of(yesterdayMorning, yesterdayNoon));
        verify(s3Service).deleteObjects(List.of(yesterdayMorning, yesterdayNoon));
    }

    @Test
    void compact_deletesAFullyStaleZipWithoutRewritingIt() {
        when(repository.zipStatistics(any())).thenReturn(List.of(statistics(LEGACY_ZIP, 2, 2)));
        when(repository.findAllByZipKeyIn(List.of(LEGACY_ZIP))).thenReturn(List.of(indexed("A_1_0", LEGACY_ZIP, LONG_AGO), indexed("B_1_0", LEGACY_ZIP, LONG_AGO)));

        underTest.compact();

        verify(s3Service, never()).downloadZip(anyString());
        verify(s3Service, never()).uploadZip(anyString(), any());
        verify(repository, never()).assignZipKey(anyString(), anyCollection());
        verify(repository).deleteAllByZipKeyIn(List.of(LEGACY_ZIP));
        verify(s3Service).deleteObjects(List.of(LEGACY_ZIP));
    }

    @Test
    void compact_leavesTheOpenZipAndTheZipsNotOverTheStaleShareAlone() {
        when(repository.zipStatistics(any())).thenReturn(List.of(statistics(OPEN_ZIP, 2, 2), statistics(LEGACY_ZIP, 10, 5), statistics(PACKED_ZIP, 10, 4)));

        underTest.compact();

        verifyNoInteractions(s3Service);
        verify(repository, never()).findAllByZipKeyIn(anyCollection());
        verify(repository, never()).deleteAllByZipKeyIn(anyCollection());
    }

    @Test
    void compact_whenASelectedZipIsMissingFromTheBucket_dropsItsRowsSoTheyAreFetchedAgainWhenReferenced() {
        when(repository.zipStatistics(any())).thenReturn(List.of(statistics(LEGACY_ZIP, 3, 2)));
        when(repository.findAllByZipKeyIn(List.of(LEGACY_ZIP))).thenReturn(List.of(
            indexed("A_1_0", LEGACY_ZIP, NOW_UTC), indexed("B_1_0", LEGACY_ZIP, LONG_AGO), indexed("C_1_0", LEGACY_ZIP, LONG_AGO)));
        when(s3Service.downloadZip(LEGACY_ZIP)).thenReturn(Optional.empty());

        underTest.compact();

        verify(s3Service, never()).uploadZip(anyString(), any());
        verify(repository, never()).assignZipKey(anyString(), anyCollection());
        verify(repository).deleteAllByZipKeyIn(List.of(LEGACY_ZIP));
        verify(s3Service).deleteObjects(List.of(LEGACY_ZIP));
    }

    private void givenXml() {
        when(xmlHelper.toString(any())).thenAnswer(invocation -> "<SegmentProfile id='" + ((SegmentProfile) invocation.getArgument(0)).getSPID() + "'/>");
    }

    private KnownSegmentProfile known(String spIdVersion, List<String> relatedLrSpIdVersions) {
        return projections.createProjection(KnownSegmentProfile.class, Map.of("spIdVersion", spIdVersion, "relatedLrSpIdVersions", relatedLrSpIdVersions));
    }

    private IndexedSegmentProfile indexed(String spIdVersion, String zipKey, OffsetDateTime lastSeen) {
        return projections.createProjection(IndexedSegmentProfile.class, Map.of("spIdVersion", spIdVersion, "zipKey", zipKey, "lastSeen", lastSeen));
    }

    private ZipStatistics statistics(String zipKey, long entries, long staleEntries) {
        return projections.createProjection(ZipStatistics.class, Map.of("zipKey", zipKey, "entries", entries, "staleEntries", staleEntries));
    }

    /** A pending SP whose XML hardly compresses, so that a few of them reach a small size cap. */
    private static PreloadedSegmentProfileEntity bulkyPending(String spIdVersion) {
        return PreloadedSegmentProfileEntity.builder().spIdVersion(spIdVersion).pendingXml(bulkyXml(spIdVersion)).lastSeen(NOW_UTC).build();
    }

    private static String bulkyXml(String id) {
        byte[] noise = new byte[300];
        new Random(id.hashCode()).nextBytes(noise);
        return "<SegmentProfile id='" + id + "'>" + Base64.getEncoder().encodeToString(noise) + "</SegmentProfile>";
    }

    private static PreloadedSegmentProfileEntity pending(String spIdVersion) {
        return PreloadedSegmentProfileEntity.builder().spIdVersion(spIdVersion).pendingXml("<pending " + spIdVersion + "/>").lastSeen(NOW_UTC).build();
    }

    private static SegmentProfileIdentification spId(String id) {
        return new SegmentProfileIdentification(id, "1", "0", "0085", null);
    }

    @SuppressWarnings("unchecked")
    private static <T> java.util.Collection<T> argThatContainsExactlyInAnyOrder(T... expected) {
        return org.mockito.ArgumentMatchers.argThat(actual -> actual != null && actual.size() == expected.length && actual.containsAll(List.of(expected)));
    }

    /** Entries of a zip in order with their content. */
    private static Map<String, String> entriesOf(byte[] zipBytes) throws IOException {
        Map<String, String> entries = new LinkedHashMap<>();
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(zipBytes), StandardCharsets.UTF_8)) {
            ZipEntry e;
            while ((e = zis.getNextEntry()) != null) {
                entries.put(e.getName(), new String(zis.readAllBytes(), StandardCharsets.UTF_8));
            }
        }
        return entries;
    }

    private static byte[] zipOf(Map<String, String> entries) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            for (Map.Entry<String, String> entry : new java.util.TreeMap<>(entries).entrySet()) {
                zos.putNextEntry(new ZipEntry(entry.getKey()));
                zos.write(entry.getValue().getBytes(StandardCharsets.UTF_8));
                zos.closeEntry();
            }
        }
        return baos.toByteArray();
    }

    private static SegmentProfile createSp(String id) {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID(id);
        sp.setSPVersionMajor("1");
        sp.setSPVersionMinor("0");
        SPZone zone = new SPZone();
        zone.setIMID("0085");
        sp.setSPZone(zone);
        return sp;
    }

    private static SegmentProfile createSpWithLocalRegulations(String id, String languageNeutralTree) {
        SegmentProfile sp = createSp(id);
        SPAreas areas = new SPAreas();
        TAFTAPLocation location = new TAFTAPLocation();
        NSPListComplexType nsp = new NSPListComplexType();
        nsp.setNSPGroupName("localRegulations");
        NetworkSpecificParameter param = new NetworkSpecificParameter();
        param.setName("languageNeutralTree");
        param.setValue(languageNeutralTree);
        nsp.getNetworkSpecificParameters().add(param);
        location.getTAFTAPLocationNSPs().add(nsp);
        areas.getTAFTAPLocations().add(location);
        sp.setSPAreas(areas);
        return sp;
    }
}
