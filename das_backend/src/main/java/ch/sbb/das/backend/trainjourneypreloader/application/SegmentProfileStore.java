package ch.sbb.das.backend.trainjourneypreloader.application;

import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.entryName;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.hourlyZipOpenedAt;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.idVersionOf;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.isSegmentZip;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.newHourlyZipKey;
import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentZipKeys.newPackedZipKey;

import ch.sbb.das.backend.common.LogKeys;
import ch.sbb.das.backend.trainjourneypreloader.domain.LocalRegulations;
import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.IndexedSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.KnownSegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository.ZipStatistics;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service.BucketObject;
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
import java.util.Comparator;
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
 * is older than {@link SegmentProfileStoreProperties#openZipMaxAge()} or is full, i.e. has reached {@link SegmentProfileStoreProperties#zipMaxBytes()}. Only hourly zips can
 * be open, so the newest hourly zip is the open one. The daily compaction rewrites the frozen hourly zips, the packed zips that are not full and the mostly stale zips into
 * packed zips, {@code Segments_<timestamp>-packed.zip}, named after the moment they were written and closed once full. The legacy numbered zips, {@code Segments_<n>.zip},
 * are treated like packed zips. Between two daily compactions the bucket therefore holds at most a day of hourly zips, one packed zip that is not full yet and otherwise
 * only full packed zips.
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
        log.atInfo().addKeyValue("pending", pending.size()).log("Segment profile publishing started");
        Instant now = clock.instant();
        Set<String> zipKeys = new HashSet<>(repository.findDistinctZipKeys());
        Optional<String> openZipKey = openZipKey(zipKeys, now);
        Optional<byte[]> existing = openZipKey.flatMap(s3Service::downloadZip);
        if (openZipKey.isPresent() && existing.isEmpty()) {
            log.atWarn().addKeyValue(LogKeys.ZIP_KEY, openZipKey.get()).log("Open segment zip missing from bucket, entries are fetched again when referenced");
            openZipKey = Optional.empty();
        }
        if (existing.isPresent() && existing.get().length >= properties.zipMaxBytes().toBytes()) {
            log.atInfo().addKeyValue(LogKeys.ZIP_KEY, openZipKey.get()).addKeyValue("bytes", existing.get().length).log("Open segment zip full and frozen");
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
                        log.atInfo()
                            .addKeyValue(LogKeys.ZIP_KEY, zipKey)
                            .addKeyValue("added", added.size())
                            .addKeyValue("bytes", bytes.length)
                            .addKeyValue("rolled", rolled)
                            .log("Segment zip published");
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
     * Runs the daily compaction once the oldest frozen hourly zip is older than {@link SegmentProfileStoreProperties#packAfter()}; until then this does nothing. The daily
     * compaction rewrites every frozen hourly zip, every other zip that is not full and every zip over {@link SegmentProfileStoreProperties#rebuildStaleShare()} stale into
     * packed zips with their live entries, each closed once it has reached {@link SegmentProfileStoreProperties#zipMaxBytes()}, then deletes their stale rows and their keys. A
     * fully stale zip is deleted without a rewrite. The open zip is never touched. An SP is stale once no journey referenced it for
     * {@link SegmentProfileStoreProperties#staleAfter()}. Whether a zip is full is read from the bucket listing; a zip the listing lacks counts as not full, so it is folded,
     * and its rows are dropped if the download misses it too.
     * <p>
     * Zips are uploaded before the index is updated, so a crash in between leaves an unreferenced zip behind, never a missing one. Segment zips the index does not
     * reference are therefore deleted from the bucket at the start of every daily compaction.
     */
    public void compact() {
        long started = System.nanoTime();
        Instant now = clock.instant();
        Set<String> zipKeys = new HashSet<>(repository.findDistinctZipKeys());
        Optional<String> openZipKey = openZipKey(zipKeys, now);
        if (!isDailyCompactionDue(zipKeys, openZipKey, now)) {
            log.atDebug().addKeyValue("packAfterMs", properties.packAfter().toMillis()).log("Segment compaction skipped, oldest frozen hourly zip is too young");
            return;
        }
        Map<String, Long> bucket = s3Service.listObjects().stream().collect(Collectors.toMap(BucketObject::key, BucketObject::size, (size, _) -> size));
        deleteUnreferencedZips(bucket.keySet(), zipKeys);
        OffsetDateTime cutoff = OffsetDateTime.ofInstant(now.minus(properties.staleAfter()), clock.getZone());
        List<String> selected = repository.zipStatistics(cutoff).stream()
            .filter(zip -> !openZipKey.equals(Optional.of(zip.getZipKey())))
            .filter(zip -> isHourlyZip(zip.getZipKey()) || !isFull(zip.getZipKey(), bucket) || isOverStaleShare(zip))
            .map(ZipStatistics::getZipKey)
            .sorted()
            .toList();
        if (selected.isEmpty()) {
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
        log.atInfo()
            .addKeyValue("oldZipKeys", selected)
            .addKeyValue("newZipKeys", packedIdVersionsByZip.keySet())
            .addKeyValue("live", live)
            .addKeyValue("evicted", rows.size() - liveRows.size())
            .addKeyValue("dropped", liveRows.size() - live)
            .addKeyValue(LogKeys.DURATION_MS, Duration.ofNanos(System.nanoTime() - started).toMillis())
            .log("Segment zips compacted");
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
            log.atWarn()
                .addKeyValue(LogKeys.ZIP_KEY, zipKey)
                .addKeyValue("liveEntries", liveEntryNames.size())
                .log("Segment zip missing from bucket, live entries dropped from the index and fetched again when referenced");
            return List.of();
        }
        return ZipWriter.entriesOf(source.get()).stream()
            .filter(entry -> liveEntryNames.contains(entry.name()))
            .toList();
    }

    /** Deletes the listed segment zips that no index row references, left behind by a crash between an upload and the index update. */
    private void deleteUnreferencedZips(Set<String> listedKeys, Set<String> referencedZipKeys) {
        List<String> unreferenced = listedKeys.stream()
            .filter(key -> isSegmentZip(key) && !referencedZipKeys.contains(key))
            .sorted()
            .toList();
        if (!unreferenced.isEmpty()) {
            log.atWarn().addKeyValue("zipKeys", unreferenced).log("Unreferenced segment zips deleted");
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

    /** The daily compaction is due once the oldest frozen hourly zip is older than the pack age. */
    private boolean isDailyCompactionDue(Set<String> zipKeys, Optional<String> openZipKey, Instant now) {
        return zipKeys.stream()
            .filter(zipKey -> !openZipKey.equals(Optional.of(zipKey)))
            .flatMap(zipKey -> hourlyZipOpenedAt(zipKey).stream())
            .min(Comparator.naturalOrder())
            .map(oldest -> oldest.plus(properties.packAfter()).isBefore(now))
            .orElse(false);
    }

    private static boolean isHourlyZip(String zipKey) {
        return hourlyZipOpenedAt(zipKey).isPresent();
    }

    private boolean isFull(String zipKey, Map<String, Long> bucket) {
        return bucket.getOrDefault(zipKey, 0L) >= properties.zipMaxBytes().toBytes();
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
