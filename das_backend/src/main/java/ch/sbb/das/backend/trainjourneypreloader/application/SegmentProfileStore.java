package ch.sbb.das.backend.trainjourneypreloader.application;

import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.FILENAME_FORMATTER;
import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.ZIP_FILE_ENDING;

import ch.sbb.das.backend.trainjourneypreloader.domain.LocalRegulations;
import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.IndexedSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.KnownSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.ZipStatistics;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration.SegmentProfileStoreProperties;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * Owns the Segment Profiles (SPs) the preloader holds for the devices: the index table and the segment zips in the preload bucket.
 * <p>
 * The index is the source of truth. A fetched SP is {@link #add added} as a pending row that keeps its XML, {@link #publish} appends the pending rows to the open segment
 * zip and marks them published, {@link #missing} tells which referenced SPs are neither pending nor published, and {@link #compact} evicts stale SPs.
 * <p>
 * Segment zips are immutable once frozen. There is one open hourly zip, {@code Segments_<timestamp>.zip}, named after the moment it was opened; it is appended to until it
 * is older than {@link SegmentProfileStoreProperties#openZipMaxAge()}. Compaction rewrites frozen zips into packed zips, {@code Segments_<timestamp>-packed.zip}, named
 * after the moment they were written. The legacy numbered zips, {@code Segments_<n>.zip}, are frozen too. Only hourly zips can be open, so the newest hourly zip is the
 * open one, and only hourly zips are packed by age: packed and legacy zips are rebuilt once they are mostly stale, never for their age alone.
 */
@Slf4j
@Service
@EnableConfigurationProperties(SegmentProfileStoreProperties.class)
public class SegmentProfileStore {

    public static final String SEGMENT_PREFIX = "Segments";

    private static final String KEY_PREFIX = SEGMENT_PREFIX + "_";
    private static final String PACKED_KEY_SUFFIX = "-packed";
    private static final String ENTRY_PREFIX = "sp/SP_";
    private static final String ENTRY_SUFFIX = ".xml";

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;
    private final PreloadedSegmentProfileRepository repository;
    private final TransactionTemplate transactionTemplate;
    private final Clock clock;
    private final SegmentProfileStoreProperties properties;

    public SegmentProfileStore(XmlHelper xmlHelper, S3Service s3Service, PreloadedSegmentProfileRepository repository, PlatformTransactionManager transactionManager,
        Clock clock, SegmentProfileStoreProperties properties) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
        this.repository = repository;
        this.transactionTemplate = new TransactionTemplate(transactionManager);
        this.clock = clock;
        this.properties = properties;
    }

    /**
     * Returns the referenced SPs the store holds neither pending nor published. Referencing an SP keeps it and the Local Regulation SPs it links to alive: their
     * {@code lastSeen} is set to now.
     */
    public Set<SegmentProfileIdentification> missing(Set<SegmentProfileIdentification> referenced) {
        if (referenced.isEmpty()) {
            return Set.of();
        }
        List<KnownSegmentProfile> known = repository.findAllBySpIdVersionIn(idVersionsOf(referenced));
        Set<String> knownIdVersions = known.stream().map(KnownSegmentProfile::getSpIdVersion).collect(Collectors.toSet());
        if (!knownIdVersions.isEmpty()) {
            Set<String> alive = new HashSet<>(knownIdVersions);
            known.stream().map(KnownSegmentProfile::getRelatedLrSpIdVersions).filter(Objects::nonNull).forEach(alive::addAll);
            repository.updateLastSeenBySpIdVersion(OffsetDateTime.now(clock), alive);
        }
        return referenced.stream().filter(id -> !knownIdVersions.contains(id.toIdVersionString())).collect(Collectors.toSet());
    }

    /**
     * Keeps the fetched SPs pending until the next {@link #publish}. SPs the store already holds are left as they are.
     */
    public void add(Collection<SegmentProfile> segmentProfiles) {
        Map<String, SegmentProfile> byIdVersion = new LinkedHashMap<>();
        segmentProfiles.forEach(sp -> byIdVersion.putIfAbsent(SegmentProfileIdentification.from(sp).toIdVersionString(), sp));
        if (byIdVersion.isEmpty()) {
            return;
        }
        Set<String> knownIdVersions = repository.findAllBySpIdVersionIn(byIdVersion.keySet()).stream().map(KnownSegmentProfile::getSpIdVersion).collect(Collectors.toSet());
        OffsetDateTime now = OffsetDateTime.now(clock);
        List<PreloadedSegmentProfileEntity> pending = byIdVersion.entrySet().stream()
            .filter(entry -> !knownIdVersions.contains(entry.getKey()))
            .map(entry -> PreloadedSegmentProfileEntity.builder()
                .spIdVersion(entry.getKey())
                .lastSeen(now)
                .pendingXml(xmlHelper.toString(entry.getValue()))
                .relatedLrSpIdVersions(relatedLrSpIdVersions(entry.getValue()))
                .build())
            .toList();
        if (!pending.isEmpty()) {
            repository.saveAll(pending);
        }
    }

    /**
     * Appends the pending SPs to the open segment zip, opening a new one when the newest hourly zip is older than {@link SegmentProfileStoreProperties#openZipMaxAge()},
     * and marks them published once the zip is uploaded. An entry a crashed publish already left in the zip is skipped.
     *
     * @return the number of SPs published
     */
    public int publish() {
        List<PreloadedSegmentProfileEntity> pending = repository.findAllByZipKeyIsNullOrderByIdAsc();
        log.info("Publishing segment profiles. pending={}", pending.size());
        if (pending.isEmpty()) {
            return 0;
        }
        Instant now = clock.instant();
        Set<String> zipKeys = new HashSet<>(repository.findDistinctZipKeys());
        Optional<String> openZipKey = openZipKey(zipKeys, now);
        String zipKey = openZipKey.orElseGet(() -> newZipKey(now, "", zipKeys));
        Optional<byte[]> existing = openZipKey.flatMap(s3Service::downloadZip);
        if (openZipKey.isPresent() && existing.isEmpty()) {
            log.warn("Open segment zip {} is missing from the bucket and is written again", zipKey);
        }
        try {
            ZipWriter zip = new ZipWriter();
            existing.ifPresent(zip::transfer);
            List<String> added = new ArrayList<>();
            for (PreloadedSegmentProfileEntity entity : pending) {
                zip.write(entryName(entity.getSpIdVersion()), entity.getPendingXml().getBytes(StandardCharsets.UTF_8));
                added.add(entity.getSpIdVersion());
            }
            byte[] bytes = zip.finish();
            s3Service.uploadZip(zipKey, bytes);
            repository.assignZipKey(zipKey, added);
            log.info("Published segment zip. key={}, added={}, bytes={}, rolled={}", zipKey, added.size(), bytes.length, openZipKey.isEmpty());
            return added.size();
        } catch (IOException e) {
            throw new UncheckedIOException("Publishing segment profiles failed", e);
        }
    }

    /**
     * Rewrites the frozen segment zips that are over {@link SegmentProfileStoreProperties#rebuildStaleShare()} stale, and the frozen hourly zips older than
     * {@link SegmentProfileStoreProperties#packAfter()}, into one packed zip with their live entries, then deletes their stale rows and their keys. A fully stale zip is
     * deleted without a rewrite. The open zip is never touched, nor is a zip that is not selected. An SP is stale once no journey referenced it for
     * {@link SegmentProfileStoreProperties#staleAfter()}.
     * <p>
     * The packed zip is uploaded before the index is updated, so a crash in between leaves an unreferenced zip behind, never a missing one; the next compaction selects
     * the same zips again.
     */
    public void compact() {
        Instant now = clock.instant();
        OffsetDateTime cutoff = OffsetDateTime.ofInstant(now.minus(properties.staleAfter()), clock.getZone());
        List<ZipStatistics> statistics = repository.zipStatistics(cutoff);
        Set<String> zipKeys = statistics.stream().map(ZipStatistics::getZipKey).collect(Collectors.toCollection(HashSet::new));
        Optional<String> openZipKey = openZipKey(zipKeys, now);
        List<String> selected = statistics.stream()
            .filter(zip -> !openZipKey.equals(Optional.of(zip.getZipKey())))
            .filter(zip -> isOverStaleShare(zip) || isHourlyZipOlderThan(zip.getZipKey(), properties.packAfter(), now))
            .map(ZipStatistics::getZipKey)
            .sorted()
            .toList();
        if (selected.isEmpty()) {
            log.debug("Segment compaction skipped: no segment zip to rebuild or pack");
            return;
        }

        List<IndexedSegmentProfile> rows = repository.findAllByZipKeyIn(selected);
        Map<String, Set<String>> liveEntryNamesByZip = rows.stream()
            .filter(row -> !row.getLastSeen().isBefore(cutoff))
            .collect(Collectors.groupingBy(IndexedSegmentProfile::getZipKey, Collectors.mapping(row -> entryName(row.getSpIdVersion()), Collectors.toSet())));

        String packedZipKey = newZipKey(now, PACKED_KEY_SUFFIX, zipKeys);
        List<String> packed = new ArrayList<>();
        try {
            ZipWriter zip = new ZipWriter();
            for (String zipKey : selected) {
                Set<String> liveEntryNames = liveEntryNamesByZip.getOrDefault(zipKey, Set.of());
                if (liveEntryNames.isEmpty()) {
                    continue;
                }
                Optional<byte[]> source = s3Service.downloadZip(zipKey);
                if (source.isEmpty()) {
                    log.warn("Segment zip {} is missing from the bucket. Its {} live entries are dropped from the index and fetched again when referenced", zipKey,
                        liveEntryNames.size());
                    continue;
                }
                try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(source.get()), StandardCharsets.UTF_8)) {
                    ZipEntry entry;
                    while ((entry = zis.getNextEntry()) != null) {
                        if (liveEntryNames.contains(entry.getName())) {
                            zip.write(entry.getName(), zis.readAllBytes());
                            packed.add(idVersionOf(entry.getName()));
                        }
                    }
                }
            }
            if (!packed.isEmpty()) {
                s3Service.uploadZip(packedZipKey, zip.finish());
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Compacting segment zips failed", e);
        }

        transactionTemplate.executeWithoutResult(status -> {
            if (!packed.isEmpty()) {
                repository.assignZipKey(packedZipKey, packed);
            }
            repository.deleteAllByZipKeyIn(selected);
        });
        s3Service.deleteObjects(selected);
        log.info("Compacted segment zips. oldKeys={}, newKey={}, live={}, deleted={}", selected, packed.isEmpty() ? null : packedZipKey, packed.size(),
            rows.size() - packed.size());
    }

    private boolean isOverStaleShare(ZipStatistics zip) {
        return zip.getEntries() > 0 && (double) zip.getStaleEntries() / zip.getEntries() > properties.rebuildStaleShare();
    }

    private static boolean isHourlyZipOlderThan(String zipKey, Duration age, Instant now) {
        return hourlyZipOpenedAt(zipKey).map(openedAt -> openedAt.plus(age).isBefore(now)).orElse(false);
    }

    /** The newest hourly zip, if it is not older than the max age. Packed and legacy zips are never open. */
    private Optional<String> openZipKey(Collection<String> zipKeys, Instant now) {
        return zipKeys.stream()
            .flatMap(zipKey -> hourlyZipOpenedAt(zipKey).map(openedAt -> Map.entry(zipKey, openedAt)).stream())
            .max(Map.Entry.comparingByValue())
            .filter(newest -> !newest.getValue().plus(properties.openZipMaxAge()).isBefore(now))
            .map(Map.Entry::getKey);
    }

    /**
     * A key named after now that no zip uses yet. A new hourly zip is also named after a later second than every existing hourly zip, so that it is the newest one.
     */
    private static String newZipKey(Instant now, String suffix, Set<String> zipKeys) {
        Instant stamp = now.truncatedTo(ChronoUnit.SECONDS);
        if (suffix.isEmpty()) {
            Instant newest = zipKeys.stream().flatMap(zipKey -> hourlyZipOpenedAt(zipKey).stream()).max(Comparator.naturalOrder()).orElse(Instant.MIN);
            if (!stamp.isAfter(newest)) {
                stamp = newest.plusSeconds(1);
            }
        }
        String zipKey;
        while (zipKeys.contains(zipKey = KEY_PREFIX + FILENAME_FORMATTER.format(stamp.atOffset(ZoneOffset.UTC)) + suffix + ZIP_FILE_ENDING)) {
            stamp = stamp.plusSeconds(1);
        }
        zipKeys.add(zipKey);
        return zipKey;
    }

    private static Optional<Instant> hourlyZipOpenedAt(String zipKey) {
        if (!zipKey.startsWith(KEY_PREFIX) || !zipKey.endsWith(ZIP_FILE_ENDING)) {
            return Optional.empty();
        }
        String stamp = zipKey.substring(KEY_PREFIX.length(), zipKey.length() - ZIP_FILE_ENDING.length());
        if (stamp.endsWith(PACKED_KEY_SUFFIX)) {
            return Optional.empty();
        }
        try {
            return Optional.of(OffsetDateTime.parse(stamp, FILENAME_FORMATTER).toInstant());
        } catch (DateTimeParseException e) {
            return Optional.empty();
        }
    }

    private static Set<String> idVersionsOf(Set<SegmentProfileIdentification> ids) {
        return ids.stream().map(SegmentProfileIdentification::toIdVersionString).collect(Collectors.toSet());
    }

    private static List<String> relatedLrSpIdVersions(SegmentProfile sp) {
        return LocalRegulations.extractSpIds(sp).stream()
            .map(SegmentProfileIdentification::toIdVersionString)
            .sorted()
            .toList();
    }

    private static String entryName(String idVersion) {
        return ENTRY_PREFIX + idVersion + ENTRY_SUFFIX;
    }

    private static String idVersionOf(String entryName) {
        return entryName.substring(ENTRY_PREFIX.length(), entryName.length() - ENTRY_SUFFIX.length());
    }

    /** Builds one segment zip in memory, skipping an entry name that was already written. */
    private static final class ZipWriter {

        private final ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        private final ZipOutputStream zip = new ZipOutputStream(bytes, StandardCharsets.UTF_8);
        private final Set<String> names = new HashSet<>();

        void transfer(byte[] existingZip) {
            try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(existingZip), StandardCharsets.UTF_8)) {
                ZipEntry entry;
                while ((entry = zis.getNextEntry()) != null) {
                    write(entry.getName(), zis.readAllBytes());
                }
            } catch (IOException e) {
                throw new UncheckedIOException("Reading the existing segment zip failed", e);
            }
        }

        void write(String name, byte[] content) throws IOException {
            if (!names.add(name)) {
                log.warn("Duplicate entry {} in segment zip skipped", name);
                return;
            }
            zip.putNextEntry(new ZipEntry(name));
            zip.write(content);
            zip.closeEntry();
        }

        byte[] finish() throws IOException {
            zip.close();
            return bytes.toByteArray();
        }
    }
}
