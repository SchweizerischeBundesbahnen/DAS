package ch.sbb.das.backend.trainjourneypreloader.application;

import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.entryName;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.hourlyZipOpenedAt;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.idVersionOf;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.isSegmentZip;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.newHourlyZipKey;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.newPackedZipKey;

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
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Deque;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
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
 * is older than {@link SegmentProfileStoreProperties#openZipMaxAge()} or has reached {@link SegmentProfileStoreProperties#zipMaxBytes()}. Compaction rewrites frozen
 * zips into packed zips, {@code Segments_<timestamp>-packed.zip}, named after the moment they were written and capped at the same size. The legacy numbered zips, {@code Segments_<n>.zip}, are frozen too. Only hourly zips can be open, so the newest hourly zip is the
 * open one, and only hourly zips are packed by age: packed and legacy zips are rebuilt once they are mostly stale, never for their age alone.
 */
@Slf4j
@Service
@EnableConfigurationProperties(SegmentProfileStoreProperties.class)
public class SegmentProfileStore {

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
        Set<String> knownIdVersions = known.stream()
            .map(KnownSegmentProfile::getSpIdVersion)
            .collect(Collectors.toSet());
        if (!knownIdVersions.isEmpty()) {
            Set<String> alive = new HashSet<>(knownIdVersions);
            known.stream().map(KnownSegmentProfile::getRelatedLrSpIdVersions).filter(Objects::nonNull).forEach(alive::addAll);
            repository.updateLastSeenBySpIdVersion(OffsetDateTime.now(clock), alive);
        }
        return referenced.stream()
            .filter(id -> !knownIdVersions.contains(id.toIdVersionString()))
            .collect(Collectors.toSet());
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
        Set<String> knownIdVersions = repository.findAllBySpIdVersionIn(byIdVersion.keySet()).stream()
            .map(KnownSegmentProfile::getSpIdVersion)
            .collect(Collectors.toSet());
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
     * Appends the pending SPs to the open segment zip and marks them published once the zip is uploaded. A new zip is opened when the newest hourly zip is older than
     * {@link SegmentProfileStoreProperties#openZipMaxAge()} or has reached {@link SegmentProfileStoreProperties#zipMaxBytes()}; a zip that reaches the size while
     * entries are appended is closed after that entry and the remaining entries continue in the next one, so a zip may exceed the size by one entry. An entry a crashed publish already left in the zip is skipped.
     *
     * @return the number of SPs published
     */
    public int publish() {
        Deque<PreloadedSegmentProfileEntity> pending = new ArrayDeque<>(repository.findAllByZipKeyIsNullOrderByIdAsc());
        if (pending.isEmpty()) {
            return 0;
        }
        log.info("Publishing segment profiles. pending={}", pending.size());
        Instant now = clock.instant();
        Set<String> zipKeys = new HashSet<>(repository.findDistinctZipKeys());
        Optional<String> openZipKey = openZipKey(zipKeys, now);
        Optional<byte[]> existing = openZipKey.flatMap(s3Service::downloadZip);
        if (openZipKey.isPresent() && existing.isEmpty()) {
            log.warn("Open segment zip {} is missing from the bucket. Its entries are fetched again when referenced", openZipKey.get());
            openZipKey = Optional.empty();
        }
        if (existing.isPresent() && existing.get().length >= properties.zipMaxBytes().toBytes()) {
            log.info("Open segment zip {} has reached {} bytes and is frozen", openZipKey.get(), existing.get().length);
            openZipKey = Optional.empty();
            existing = Optional.empty();
        }
        String zipKey = openZipKey.orElseGet(() -> newHourlyZipKey(now, zipKeys));
        boolean rolled = openZipKey.isEmpty();
        long zipMaxBytes = properties.zipMaxBytes().toBytes();
        int published = 0;
        try {
            while (!pending.isEmpty()) {
                List<String> added = new ArrayList<>();
                try (ZipWriter zip = new ZipWriter()) {
                    existing.ifPresent(zip::transfer);
                    existing = Optional.empty();
                    while (!pending.isEmpty() && zip.size() < zipMaxBytes) {
                        PreloadedSegmentProfileEntity entity = pending.poll();
                        zip.write(entryName(entity.getSpIdVersion()), entity.getPendingXml().getBytes(StandardCharsets.UTF_8));
                        added.add(entity.getSpIdVersion());
                    }
                    if (!added.isEmpty()) {
                        byte[] bytes = zip.finish();
                        s3Service.uploadZip(zipKey, bytes);
                        repository.assignZipKey(zipKey, added);
                        log.info("Published segment zip. key={}, added={}, bytes={}, rolled={}", zipKey, added.size(), bytes.length, rolled);
                        published += added.size();
                    }
                }
                if (!pending.isEmpty()) {
                    zipKey = newHourlyZipKey(now, zipKeys);
                    rolled = true;
                }
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Publishing segment profiles failed", e);
        }
        return published;
    }

    /**
     * Rewrites the frozen segment zips that are over {@link SegmentProfileStoreProperties#rebuildStaleShare()} stale, and the frozen hourly zips older than
     * {@link SegmentProfileStoreProperties#packAfter()}, into packed zips with their live entries, each closed once it has reached {@link SegmentProfileStoreProperties#zipMaxBytes()}, then
     * deletes their stale rows and their keys. A fully stale zip is deleted without a rewrite. The open zip is never touched, nor is a zip that is not selected. An SP is
     * stale once no journey referenced it for {@link SegmentProfileStoreProperties#staleAfter()}.
     * <p>
     * Zips are uploaded before the index is updated, so a crash in between leaves an unreferenced zip behind, never a missing one. Segment zips the index does not
     * reference are therefore deleted from the bucket at the end of every compaction.
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
            deleteUnreferencedZips(zipKeys);
            return;
        }

        List<IndexedSegmentProfile> rows = repository.findAllByZipKeyIn(selected);
        List<IndexedSegmentProfile> liveRows = rows.stream().filter(row -> !row.getLastSeen().isBefore(cutoff)).toList();
        Map<String, Set<String>> liveEntryNamesByZip = liveRows.stream()
            .collect(Collectors.groupingBy(IndexedSegmentProfile::getZipKey, Collectors.mapping(row -> entryName(row.getSpIdVersion()), Collectors.toSet())));

        Map<String, List<String>> packedIdVersionsByZip = packLiveEntries(selected, liveEntryNamesByZip, now, zipKeys);

        transactionTemplate.executeWithoutResult(status -> {
            packedIdVersionsByZip.forEach(repository::assignZipKey);
            repository.deleteAllByZipKeyIn(selected);
        });
        s3Service.deleteObjects(selected);
        int live = packedIdVersionsByZip.values().stream().mapToInt(List::size).sum();
        log.info("Compacted segment zips. oldKeys={}, newKeys={}, live={}, evicted={}, dropped={}", selected, packedIdVersionsByZip.keySet(), live,
            rows.size() - liveRows.size(), liveRows.size() - live);
        deleteUnreferencedZips(zipKeys);
    }

    /** Writes the live entries of the selected zips into packed zips, each closed once it has reached the size, and returns the SPs of each packed zip. */
    private Map<String, List<String>> packLiveEntries(List<String> selected, Map<String, Set<String>> liveEntryNamesByZip, Instant now, Set<String> zipKeys) {
        Map<String, List<String>> packedIdVersionsByZip = new LinkedHashMap<>();
        long zipMaxBytes = properties.zipMaxBytes().toBytes();
        PackedZip packed = new PackedZip(newPackedZipKey(now, zipKeys));
        try {
            for (String zipKey : selected) {
                for (ZipWriter.Entry entry : liveEntriesOf(zipKey, liveEntryNamesByZip.getOrDefault(zipKey, Set.of()))) {
                    if (packed.zip.size() >= zipMaxBytes) {
                        packedIdVersionsByZip.put(packed.key, packed.upload());
                        packed = new PackedZip(newPackedZipKey(now, zipKeys));
                    }
                    packed.zip.write(entry.name(), entry.content());
                    packed.idVersions.add(idVersionOf(entry.name()));
                }
            }
            if (!packed.idVersions.isEmpty()) {
                packedIdVersionsByZip.put(packed.key, packed.upload());
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Compacting segment zips failed", e);
        } finally {
            packed.zip.close();
        }
        return packedIdVersionsByZip;
    }

    /** The entries of the zip that are live; none when the zip is missing from the bucket. */
    private List<ZipWriter.Entry> liveEntriesOf(String zipKey, Set<String> liveEntryNames) throws IOException {
        if (liveEntryNames.isEmpty()) {
            return List.of();
        }
        Optional<byte[]> source = s3Service.downloadZip(zipKey);
        if (source.isEmpty()) {
            log.warn("Segment zip {} is missing from the bucket. Its {} live entries are dropped from the index and fetched again when referenced", zipKey,
                liveEntryNames.size());
            return List.of();
        }
        return ZipWriter.entriesOf(source.get()).stream()
            .filter(entry -> liveEntryNames.contains(entry.name()))
            .toList();
    }

    /** Deletes the segment zips in the bucket that no index row references, left behind by a crash between an upload and the index update. */
    private void deleteUnreferencedZips(Set<String> referencedZipKeys) {
        List<String> unreferenced = s3Service.listObjects().stream()
            .filter(key -> isSegmentZip(key) && !referencedZipKeys.contains(key))
            .sorted()
            .toList();
        if (!unreferenced.isEmpty()) {
            log.warn("Deleting {} segment zips the index does not reference: {}", unreferenced.size(), unreferenced);
            s3Service.deleteObjects(unreferenced);
        }
    }

    /** A packed zip under construction: its key, its bytes and the SPs written to it. */
    private final class PackedZip {

        private final String key;
        private final ZipWriter zip = new ZipWriter();
        private final List<String> idVersions = new ArrayList<>();

        private PackedZip(String key) {
            this.key = key;
        }

        /** Uploads the zip and returns the SPs it holds. */
        private List<String> upload() throws IOException {
            s3Service.uploadZip(key, zip.finish());
            zip.close();
            return idVersions;
        }
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

    private static Set<String> idVersionsOf(Set<SegmentProfileIdentification> ids) {
        return ids.stream().map(SegmentProfileIdentification::toIdVersionString).collect(Collectors.toSet());
    }

    private static List<String> relatedLrSpIdVersions(SegmentProfile sp) {
        return LocalRegulations.extractSpIds(sp).stream()
            .map(SegmentProfileIdentification::toIdVersionString)
            .sorted()
            .toList();
    }
}
