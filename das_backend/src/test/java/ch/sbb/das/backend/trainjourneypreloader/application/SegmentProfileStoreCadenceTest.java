package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anySet;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.IndexedSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.KnownSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.ZipStatistics;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service.BucketObject;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration.SegmentProfileStoreProperties;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPZone;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.projection.ProjectionFactory;
import org.springframework.data.projection.SpelAwareProxyProjectionFactory;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.util.unit.DataSize;

/**
 * Replays the 5-minute preload cadence over several days against an in-memory bucket and index, so that rules which only hold when zips cross an age one at a time are
 * caught here.
 */
@ExtendWith(MockitoExtension.class)
class SegmentProfileStoreCadenceTest {

    private static final Instant START = Instant.parse("2026-11-15T11:02:00Z");
    private static final Duration TICK = Duration.ofMinutes(5);
    private static final Duration REPLAY = Duration.ofHours(60);
    private static final DataSize ZIP_MAX_BYTES = DataSize.ofKilobytes(3);
    private static final String RUN_ZIP = "2026-11-15T10-57-00Z.zip";

    private final ProjectionFactory projections = new SpelAwareProxyProjectionFactory();
    private final Map<String, byte[]> bucket = new TreeMap<>();
    private final Map<String, Row> index = new LinkedHashMap<>();
    private final Set<Instant> foldTicks = new TreeSet<>();
    private Instant now = START;

    @Mock
    private XmlHelper xmlHelper;

    @Mock
    private S3Service s3Service;

    @Mock
    private PreloadedSegmentProfileRepository repository;

    @Mock
    private PlatformTransactionManager transactionManager;

    @Mock
    private Clock clock;

    private SegmentProfileStore underTest;

    @BeforeEach
    void setUp() throws IOException {
        when(clock.instant()).thenAnswer(_ -> now);
        when(clock.getZone()).thenReturn(ZoneOffset.UTC);
        when(xmlHelper.toString(any())).thenAnswer(invocation -> bulkyXml(((SegmentProfile) invocation.getArgument(0)).getSPID()));
        stubBucket();
        stubIndex();
        SegmentProfileStoreProperties properties = new SegmentProfileStoreProperties(Duration.ofDays(30), 0.5, Duration.ofHours(1), Duration.ofHours(24), ZIP_MAX_BYTES);
        underTest = new SegmentProfileStore(xmlHelper, s3Service, repository, transactionManager, clock, properties);

        seedLegacyZip("Segments_7.zip", Map.of("L1_1_0", START, "L2_1_0", START));
        seedLegacyZip("Segments_8.zip", Map.of("L3_1_0", START, "STALE_1_0", START.minus(Duration.ofDays(40))));
        bucket.put(RUN_ZIP, new byte[] {1, 2, 3});
    }

    @Test
    void compactsOnceADayAndKeepsTheBucketBounded() throws IOException {
        int ticks = (int) (REPLAY.toMinutes() / TICK.toMinutes());
        int added = 0;
        for (int tick = 0; tick <= ticks; tick++) {
            now = START.plus(TICK.multipliedBy(tick));
            int minute = now.atOffset(ZoneOffset.UTC).getMinute();
            if (minute == 2 || minute == 32) {
                underTest.add(List.of(createSp("SP-" + tick + "a"), createSp("SP-" + tick + "b"), createSp("SP-" + tick + "c")));
                added += 3;
            }
            underTest.publish();
            underTest.compact();
            assertInvariants();
        }

        assertThat(foldTicks).as("one daily compaction per day").hasSize(2);
        List<Instant> folds = new ArrayList<>(foldTicks);
        assertThat(Duration.between(folds.get(0), folds.get(1))).isGreaterThanOrEqualTo(Duration.ofHours(23));
        assertThat(folds.getFirst()).isAfter(START.plus(Duration.ofHours(24)));
        assertThat(bucket.keySet()).contains(RUN_ZIP).doesNotContain("Segments_7.zip", "Segments_8.zip");
        assertThat(index).doesNotContainKey("STALE_1_0").containsKeys("L1_1_0", "L2_1_0", "L3_1_0");
        assertThat(index).hasSize(added + 3);
        assertThat(index.values().stream().filter(row -> row.zipKey.endsWith("-packed.zip")).map(row -> row.spIdVersion).toList())
            .as("everything but the hourly zips of the last day is packed")
            .contains("L1_1_0", "L2_1_0", "L3_1_0", "SP-0a_1_0");
    }

    /** Every SP is in exactly one segment zip, the bucket holds no segment zip the index does not know, and the zip count stays bounded. */
    private void assertInvariants() throws IOException {
        Set<String> segmentZips = bucket.keySet().stream().filter(key -> key.startsWith("Segments_")).collect(Collectors.toSet());
        Set<String> indexedZips = index.values().stream().map(row -> row.zipKey).collect(Collectors.toSet());
        assertThat(indexedZips).as("at " + now).doesNotContainNull().isEqualTo(segmentZips);

        List<String> entryNames = new ArrayList<>();
        for (String zipKey : segmentZips) {
            entryNames.addAll(entriesOf(bucket.get(zipKey)));
        }
        Set<String> indexedEntryNames = index.keySet().stream().map(SegmentZipKeys::entryName).collect(Collectors.toSet());
        assertThat(entryNames).as("at " + now).doesNotHaveDuplicates().containsExactlyInAnyOrderElementsOf(indexedEntryNames);

        long hourly = segmentZips.stream().filter(key -> SegmentZipKeys.hourlyZipOpenedAt(key).isPresent()).count();
        long notFullPacked = segmentZips.stream().filter(key -> key.endsWith("-packed.zip") && bucket.get(key).length < ZIP_MAX_BYTES.toBytes()).count();
        assertThat(hourly).as("hourly zips at " + now).isLessThanOrEqualTo(25);
        assertThat(notFullPacked).as("packed zips that are not full at " + now).isLessThanOrEqualTo(1);
    }

    private void stubBucket() {
        doAnswer(invocation -> {
            String key = invocation.getArgument(0);
            bucket.put(key, invocation.getArgument(1));
            if (key.endsWith("-packed.zip")) {
                foldTicks.add(now);
            }
            return null;
        }).when(s3Service).uploadZip(anyString(), any());
        when(s3Service.downloadZip(anyString())).thenAnswer(invocation -> Optional.ofNullable(bucket.get((String) invocation.getArgument(0))));
        when(s3Service.listObjects()).thenAnswer(_ -> bucket.entrySet().stream().map(entry -> new BucketObject(entry.getKey(), entry.getValue().length)).toList());
        doAnswer(invocation -> {
            invocation.<List<String>>getArgument(0).forEach(bucket::remove);
            return null;
        }).when(s3Service).deleteObjects(anyList());
    }

    private void stubIndex() {
        when(repository.findAllBySpIdVersionIn(anySet())).thenAnswer(invocation -> invocation.<Collection<String>>getArgument(0).stream()
            .filter(index::containsKey)
            .map(spIdVersion -> projections.createProjection(KnownSegmentProfile.class, Map.of("spIdVersion", spIdVersion, "relatedLrSpIdVersions", List.of())))
            .toList());
        when(repository.saveAll(anyList())).thenAnswer(invocation -> {
            List<PreloadedSegmentProfileEntity> entities = invocation.getArgument(0);
            entities.forEach(entity -> index.put(entity.getSpIdVersion(), new Row(entity.getSpIdVersion(), null, entity.getLastSeen(), entity.getPendingXml())));
            return entities;
        });
        when(repository.findAllByZipKeyIsNullOrderByIdAsc()).thenAnswer(_ -> index.values().stream()
            .filter(row -> row.zipKey == null)
            .map(row -> PreloadedSegmentProfileEntity.builder().spIdVersion(row.spIdVersion).pendingXml(row.pendingXml).lastSeen(row.lastSeen).build())
            .toList());
        when(repository.findDistinctZipKeys()).thenAnswer(_ -> index.values().stream().map(row -> row.zipKey).filter(key -> key != null).distinct().toList());
        doAnswer(invocation -> {
            String zipKey = invocation.getArgument(0);
            invocation.<Collection<String>>getArgument(1).forEach(spIdVersion -> {
                Row row = index.get(spIdVersion);
                index.put(spIdVersion, new Row(spIdVersion, zipKey, row.lastSeen, null));
            });
            return null;
        }).when(repository).assignZipKey(anyString(), anyCollection());
        when(repository.zipStatistics(any())).thenAnswer(invocation -> {
            OffsetDateTime cutoff = invocation.getArgument(0);
            Map<String, List<Row>> byZip = index.values().stream().filter(row -> row.zipKey != null).collect(Collectors.groupingBy(row -> row.zipKey));
            return byZip.entrySet().stream()
                .map(entry -> projections.createProjection(ZipStatistics.class, Map.of("zipKey", entry.getKey(), "entries", (long) entry.getValue().size(),
                    "staleEntries", entry.getValue().stream().filter(row -> row.lastSeen.isBefore(cutoff)).count())))
                .toList();
        });
        when(repository.findAllByZipKeyIn(anyCollection())).thenAnswer(invocation -> {
            Set<String> zipKeys = new HashSet<>(invocation.<Collection<String>>getArgument(0));
            return index.values().stream()
                .filter(row -> zipKeys.contains(row.zipKey))
                .map(row -> projections.createProjection(IndexedSegmentProfile.class, Map.of("spIdVersion", row.spIdVersion, "zipKey", row.zipKey, "lastSeen", row.lastSeen)))
                .toList();
        });
        doAnswer(invocation -> {
            Set<String> zipKeys = new HashSet<>(invocation.<Collection<String>>getArgument(0));
            index.values().removeIf(row -> zipKeys.contains(row.zipKey));
            return null;
        }).when(repository).deleteAllByZipKeyIn(anyCollection());
    }

    private void seedLegacyZip(String zipKey, Map<String, Instant> lastSeenBySpIdVersion) throws IOException {
        Map<String, String> entries = new TreeMap<>();
        lastSeenBySpIdVersion.forEach((spIdVersion, lastSeen) -> {
            entries.put(SegmentZipKeys.entryName(spIdVersion), bulkyXml(spIdVersion));
            index.put(spIdVersion, new Row(spIdVersion, zipKey, lastSeen.atOffset(ZoneOffset.UTC), null));
        });
        bucket.put(zipKey, zipOf(entries));
    }

    /** An index row: its zip key is null while the SP is pending. */
    private record Row(String spIdVersion, String zipKey, OffsetDateTime lastSeen, String pendingXml) {

    }

    /** XML that hardly compresses, so that a handful of SPs fills a small zip. */
    private static String bulkyXml(String id) {
        byte[] noise = new byte[300];
        new Random(id.hashCode()).nextBytes(noise);
        return "<SegmentProfile id='" + id + "'>" + Base64.getEncoder().encodeToString(noise) + "</SegmentProfile>";
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

    private static List<String> entriesOf(byte[] zipBytes) throws IOException {
        List<String> names = new ArrayList<>();
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(zipBytes), StandardCharsets.UTF_8)) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                names.add(entry.getName());
            }
        }
        return names;
    }

    private static byte[] zipOf(Map<String, String> entries) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            for (Map.Entry<String, String> entry : entries.entrySet()) {
                zos.putNextEntry(new ZipEntry(entry.getKey()));
                zos.write(entry.getValue().getBytes(StandardCharsets.UTF_8));
                zos.closeEntry();
            }
        }
        return baos.toByteArray();
    }
}
