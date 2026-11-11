package ch.sbb.das.backend.trainjourneypreloader.application;

import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.ZIP_FILE_ENDING;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.trainjourneypreloader.domain.LocalRegulations;
import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Limit;
import org.springframework.stereotype.Service;

/**
 * Owns the Segment Profiles (SPs) the preloader has published for the devices: the index table and the segment zips in the preload bucket. The rest of the preloader asks
 * which referenced SPs are {@link #missing}, hands fetched SPs over with {@link #save} and lets the store {@link #compact} the zips.
 */
@Slf4j
@Service
public class SegmentProfileStore {

    public static final String SEGMENT_PREFIX = "Segments";
    static final String DIR_SP = "sp/";

    private static final String DUPLICATE_ENTRY_KEY = "duplicate entry";
    private static final int MAX_SEGMENTS_PER_ZIP = 1000;
    private static final int STALE_SEGMENTS_THRESHOLD = 1000;
    private static final int STALE_SEGMENTS_DAYS = 30;

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;
    private final PreloadedSegmentProfileRepository repository;

    public SegmentProfileStore(XmlHelper xmlHelper, S3Service s3Service, PreloadedSegmentProfileRepository repository) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
        this.repository = repository;
    }

    /**
     * Returns the referenced SPs the store does not hold. Referencing an SP keeps it and the Local Regulation SPs it links to alive: their {@code lastSeen} is set to now.
     */
    public Set<SegmentProfileIdentification> missing(Set<SegmentProfileIdentification> referenced) {
        if (referenced.isEmpty()) {
            return Set.of();
        }
        Set<String> referencedIdVersions = referenced.stream().map(SegmentProfileIdentification::toIdVersionString).collect(Collectors.toSet());
        List<PreloadedSegmentProfileEntity> known = repository.findAllBySpIdVersionIn(referencedIdVersions);
        Set<String> knownIdVersions = known.stream().map(PreloadedSegmentProfileEntity::getSpIdVersion).collect(Collectors.toSet());
        Set<String> relatedLrIdVersions = known.stream()
            .map(PreloadedSegmentProfileEntity::getRelatedLrSpIdVersions)
            .filter(Objects::nonNull)
            .flatMap(List::stream)
            .collect(Collectors.toSet());
        if (!relatedLrIdVersions.isEmpty()) {
            repository.updateLastSeenBySpIdVersion(DateTimeUtil.now(), relatedLrIdVersions);
        }
        repository.updateLastSeenBySpIdVersion(DateTimeUtil.now(), knownIdVersions);
        return referenced.stream().filter(id -> !knownIdVersions.contains(id.toIdVersionString())).collect(Collectors.toSet());
    }

    /**
     * Appends the SPs to the newest segment zip, opening a new one once it holds {@value #MAX_SEGMENTS_PER_ZIP} entries, and indexes them.
     */
    public void save(Collection<SegmentProfile> segmentProfiles) {
        if (segmentProfiles == null || segmentProfiles.isEmpty()) {
            return;
        }
        try {
            int fileId = 1;
            int fileCount = 0;
            Optional<Integer> latestFileId = repository.findMaxFileId();
            if (latestFileId.isPresent()) {
                fileId = latestFileId.get();
                fileCount = repository.countByFileId(fileId);
            }

            List<SegmentProfile> remaining = new ArrayList<>(segmentProfiles);
            OffsetDateTime now = DateTimeUtil.now();
            int index = 0;

            while (index < remaining.size()) {
                List<PreloadedSegmentProfileEntity> toSave = new ArrayList<>();

                if (fileCount >= MAX_SEGMENTS_PER_ZIP) {
                    fileId++;
                    fileCount = 0;
                }
                int spaceLeft = MAX_SEGMENTS_PER_ZIP - fileCount;
                int end = Math.min(index + spaceLeft, remaining.size());
                List<SegmentProfile> batch = remaining.subList(index, end);

                writeSegmentsToZip(fileId, batch);

                for (SegmentProfile sp : batch) {
                    toSave.add(PreloadedSegmentProfileEntity.builder()
                        .spIdVersion(SegmentProfileIdentification.from(sp).toIdVersionString())
                        .lastSeen(now)
                        .fileId(fileId)
                        .relatedLrSpIdVersions(relatedLrSpIdVersions(sp))
                        .build());
                }

                fileCount += batch.size();
                index = end;

                repository.saveAll(toSave);
            }

        } catch (Exception e) {
            throw new RuntimeException("Preload saveSegments failed", e);
        }
    }

    /**
     * Removes segments that have not been registered (lastSeen updated) for more than {@link #STALE_SEGMENTS_DAYS} days from their segment zip files, and compacts the remaining segments so that the
     * zip files are filled up to max entries again. The cleanup only runs once the number of stale segments exceeds {@link #STALE_SEGMENTS_THRESHOLD}, so that at least one full zip can be freed.
     */
    public void compact() {
        OffsetDateTime cutoff = DateTimeUtil.now().minusDays(STALE_SEGMENTS_DAYS);
        int staleCount = repository.countByLastSeenBefore(cutoff);
        if (staleCount <= STALE_SEGMENTS_THRESHOLD) {
            log.debug("Segment cleanup skipped: only {} stale segments (threshold {})", staleCount, STALE_SEGMENTS_THRESHOLD);
            return;
        }
        log.info("Segment cleanup started. staleCount={}", staleCount);

        Map<Integer, List<PreloadedSegmentProfileEntity>> stalePreloadedSegments = findStalePreloadedSegments(cutoff);

        List<PreloadedSegmentProfileEntity> fillerPreloadedSegments = repository.findByLastSeenAfterOrderByFileIdDesc(cutoff, Limit.of(staleCount));
        Map<Integer, List<PreloadedSegmentProfileEntity>> fillersByOriginalFile = fillerPreloadedSegments.stream()
            .filter(e -> e.getFileId() != null)
            .collect(Collectors.groupingBy(PreloadedSegmentProfileEntity::getFileId));

        Map<String, PreloadedSegmentProfileEntity> staleEntryNames = buildEntryNameLookup(stalePreloadedSegments.values().stream().flatMap(Collection::stream).toList());

        try {
            Map<PreloadedSegmentProfileEntity, byte[]> fillerSegments = loadFillerSegments(fillerPreloadedSegments);

            Map<Integer, List<PreloadedSegmentProfileEntity>> fillersPerTargetFile = assignFillersToTargetFiles(stalePreloadedSegments, fillerSegments);

            replaceStaleWithFillers(stalePreloadedSegments, staleEntryNames, fillersPerTargetFile, fillerSegments);

            removeFillerEntriesFromOriginalZips(fillersByOriginalFile);

            int relocated = fillersPerTargetFile.values().stream().mapToInt(List::size).sum();
            log.info("Segment cleanup completed. removed={}, relocated={}", staleEntryNames.size(), relocated);

        } catch (IOException e) {
            throw new RuntimeException("Segment cleanup failed", e);
        }
    }

    private void writeSegmentsToZip(int fileIndex, Collection<SegmentProfile> segmentProfiles) throws IOException {
        String key = buildSegmentZipName(fileIndex);
        Optional<byte[]> existing = s3Service.downloadZip(key);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            transferExistingEntries(existing, zos);
            writeSps(segmentProfiles, zos);
        }

        s3Service.uploadZip(key, baos.toByteArray());
    }

    private void writeSps(Collection<SegmentProfile> sps, ZipOutputStream zos) throws IOException {
        for (SegmentProfile sp : sps) {
            writeXmlEntry(zos, buildSegmentEntryName(SegmentProfileIdentification.from(sp).toIdVersionString()), sp);
        }
    }

    private List<String> relatedLrSpIdVersions(SegmentProfile sp) {
        return LocalRegulations.extractSpIds(sp).stream()
            .map(SegmentProfileIdentification::toIdVersionString)
            .sorted()
            .toList();
    }

    private void writeXmlEntry(ZipOutputStream zos, String entryName, Object obj) throws IOException {
        if (obj == null) {
            return;
        }
        String xml = xmlHelper.toString(obj);
        ZipEntry entry = new ZipEntry(entryName);
        try {
            zos.putNextEntry(entry);
        } catch (ZipException e) {
            if (e.getMessage().contains(DUPLICATE_ENTRY_KEY)) {
                log.warn("Duplicate file {} in zip file skipped", entryName);
                zos.closeEntry();
                return;
            }
            throw e;
        }
        zos.write(xml.getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }

    private void transferExistingEntries(Optional<byte[]> existing, ZipOutputStream zos) throws IOException {
        if (existing.isPresent()) {
            try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(existing.get()), StandardCharsets.UTF_8)) {
                ZipEntry entry;
                while ((entry = zis.getNextEntry()) != null) {
                    zos.putNextEntry(new ZipEntry(entry.getName()));
                    zis.transferTo(zos);
                    zos.closeEntry();
                }
            }
        }
    }

    private Map<String, PreloadedSegmentProfileEntity> buildEntryNameLookup(List<PreloadedSegmentProfileEntity> entities) {
        return entities.stream().collect(Collectors.toMap(e -> buildSegmentEntryName(e.getSpIdVersion()), e -> e));
    }

    private Map<Integer, List<PreloadedSegmentProfileEntity>> assignFillersToTargetFiles(Map<Integer, List<PreloadedSegmentProfileEntity>> stalePreloadedSegments,
        Map<PreloadedSegmentProfileEntity, byte[]> fillerSegments) {

        List<PreloadedSegmentProfileEntity> fillerList = new ArrayList<>(fillerSegments.keySet());
        Map<Integer, List<PreloadedSegmentProfileEntity>> fillersPerTargetFile = new HashMap<>();
        int fillerIndex = 0;

        for (Map.Entry<Integer, List<PreloadedSegmentProfileEntity>> entry : stalePreloadedSegments.entrySet()) {
            int fillersNeeded = Math.min(entry.getValue().size(), fillerList.size() - fillerIndex);
            List<PreloadedSegmentProfileEntity> assignedFillers = fillerList.subList(fillerIndex, fillerIndex + fillersNeeded);
            fillersPerTargetFile.put(entry.getKey(), new ArrayList<>(assignedFillers));
            fillerIndex += fillersNeeded;
        }

        return fillersPerTargetFile;
    }

    private void replaceStaleWithFillers(Map<Integer, List<PreloadedSegmentProfileEntity>> stalePreloadedSegments, Map<String, PreloadedSegmentProfileEntity> staleEntryNames,
        Map<Integer, List<PreloadedSegmentProfileEntity>> fillersPerTargetFile, Map<PreloadedSegmentProfileEntity, byte[]> fillerSegments) throws IOException {

        for (Map.Entry<Integer, List<PreloadedSegmentProfileEntity>> entry : stalePreloadedSegments.entrySet()) {
            int fileId = entry.getKey();
            String zipName = buildSegmentZipName(fileId);
            Optional<byte[]> existing = s3Service.downloadZip(zipName);
            if (existing.isEmpty()) {
                log.warn("Segment zip {} not found on S3, skipping", zipName);
                continue;
            }

            List<PreloadedSegmentProfileEntity> fillers = fillersPerTargetFile.get(fileId);
            byte[] rewrittenZip = rewriteZipReplacingEntries(existing.get(), staleEntryNames, fillers, fillerSegments);
            s3Service.uploadZip(zipName, rewrittenZip);

            for (PreloadedSegmentProfileEntity filler : fillers) {
                filler.setFileId(fileId);
            }
            repository.saveAll(fillers);
            repository.deleteAll(entry.getValue());
        }
    }

    private byte[] rewriteZipReplacingEntries(byte[] existingZip, Map<String, PreloadedSegmentProfileEntity> entriesToRemove, List<PreloadedSegmentProfileEntity> entriesToAdd,
        Map<PreloadedSegmentProfileEntity, byte[]> entryData) throws IOException {

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            removeEntries(existingZip, entriesToRemove, zos);
            for (PreloadedSegmentProfileEntity entry : entriesToAdd) {
                String entryName = buildSegmentEntryName(entry.getSpIdVersion());
                zos.putNextEntry(new ZipEntry(entryName));
                zos.write(entryData.get(entry));
                zos.closeEntry();
            }
        }
        return baos.toByteArray();
    }

    private void removeEntries(byte[] existingZip, Map<String, PreloadedSegmentProfileEntity> entriesToRemove, ZipOutputStream zos) throws IOException {
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(existingZip), StandardCharsets.UTF_8)) {
            ZipEntry zipEntry;
            while ((zipEntry = zis.getNextEntry()) != null) {
                if (!entriesToRemove.containsKey(zipEntry.getName())) {
                    zos.putNextEntry(new ZipEntry(zipEntry.getName()));
                    zis.transferTo(zos);
                    zos.closeEntry();
                }
            }
        }
    }

    private void removeFillerEntriesFromOriginalZips(Map<Integer, List<PreloadedSegmentProfileEntity>> fillersByOriginalFile) throws IOException {
        for (Map.Entry<Integer, List<PreloadedSegmentProfileEntity>> fileEntry : fillersByOriginalFile.entrySet()) {
            int fileId = fileEntry.getKey();
            String key = buildSegmentZipName(fileId);
            Optional<byte[]> existing = s3Service.downloadZip(key);
            if (existing.isEmpty()) {
                continue;
            }

            Map<String, PreloadedSegmentProfileEntity> fillerNamesInFile = buildEntryNameLookup(fileEntry.getValue());
            byte[] rewrittenZip = rewriteZipRemovingEntries(existing.get(), fillerNamesInFile);

            if (hasZipEntries(rewrittenZip)) {
                s3Service.uploadZip(key, rewrittenZip);
            } else {
                s3Service.deleteObjects(List.of(key));
            }
        }
    }

    private boolean hasZipEntries(byte[] zipBytes) throws IOException {
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(zipBytes), StandardCharsets.UTF_8)) {
            return zis.getNextEntry() != null;
        }
    }

    private byte[] rewriteZipRemovingEntries(byte[] existingZip, Map<String, PreloadedSegmentProfileEntity> entriesToRemove) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            removeEntries(existingZip, entriesToRemove, zos);
        }
        return baos.toByteArray();
    }

    private Map<PreloadedSegmentProfileEntity, byte[]> loadFillerSegments(List<PreloadedSegmentProfileEntity> fillerPreloadedSegments) throws IOException {
        Map<PreloadedSegmentProfileEntity, byte[]> result = new HashMap<>();

        Map<Integer, List<PreloadedSegmentProfileEntity>> fillerByFile = fillerPreloadedSegments.stream().filter(e -> e.getFileId() != null)
            .collect(Collectors.groupingBy(PreloadedSegmentProfileEntity::getFileId));

        for (Map.Entry<Integer, List<PreloadedSegmentProfileEntity>> fileEntry : fillerByFile.entrySet()) {
            Map<String, PreloadedSegmentProfileEntity> entryNames = fileEntry.getValue().stream().collect(Collectors.toMap(e -> buildSegmentEntryName(e.getSpIdVersion()), e -> e));

            Optional<byte[]> existing = s3Service.downloadZip(buildSegmentZipName(fileEntry.getKey()));
            if (existing.isEmpty()) {
                throw new IOException("Failed to download segment zip with index " + fileEntry.getKey());
            }

            try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(existing.get()), StandardCharsets.UTF_8)) {
                ZipEntry entry;
                while ((entry = zis.getNextEntry()) != null) {
                    if (entryNames.containsKey(entry.getName())) {
                        result.put(entryNames.get(entry.getName()), zis.readAllBytes());
                    }
                }
            }
        }

        return result;
    }

    private Map<Integer, List<PreloadedSegmentProfileEntity>> findStalePreloadedSegments(OffsetDateTime cutoff) {
        List<PreloadedSegmentProfileEntity> stale = repository.findAllByLastSeenBefore(cutoff);
        return stale.stream().filter(e -> e.getFileId() != null).collect(Collectors.groupingBy(PreloadedSegmentProfileEntity::getFileId));
    }

    private String buildSegmentZipName(Integer index) {
        return String.format("%s_%d%s", SEGMENT_PREFIX, index, ZIP_FILE_ENDING);
    }

    private String buildSegmentEntryName(String idVersion) {
        return DIR_SP + "SP_" + idVersion + ".xml";
    }
}
