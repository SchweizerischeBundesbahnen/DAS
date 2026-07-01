package ch.sbb.das.backend.trainjourneypreloader.application;

import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.DIR_SP;
import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.FILENAME_FORMATTER;
import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.SEGMENT_PREFIX;
import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.ZIP_FILE_ENDING;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Limit;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class CleanupStorageService {

    private static final int STALE_SEGMENTS_THRESHOLD = 1000;
    private static final int STALE_SEGMENTS_DAYS = 30;

    private final S3Service s3Service;
    private final PreloadedSegmentProfileRepository preloadedSegmentProfileRepository;

    public CleanupStorageService(S3Service s3Service, PreloadedSegmentProfileRepository preloadedSegmentProfileRepository) {
        this.s3Service = s3Service;
        this.preloadedSegmentProfileRepository = preloadedSegmentProfileRepository;
    }

    void deleteAllBefore(OffsetDateTime cutoffDate) {
        List<String> keysToDelete = s3Service.listObjects().stream()
            .filter(k -> k != null && k.endsWith(ZIP_FILE_ENDING) && !k.contains(SEGMENT_PREFIX))
            .filter(k -> {
                try {
                    String base = k.substring(0, k.length() - ZIP_FILE_ENDING.length());
                    OffsetDateTime ts = OffsetDateTime.parse(base, FILENAME_FORMATTER);
                    return ts.isBefore(cutoffDate);
                } catch (DateTimeParseException e) {
                    log.warn("Unexpected zip file name while preload cleanup. name={} was not deleted", k);
                    return false;
                }
            }).toList();

        if (!keysToDelete.isEmpty()) {
            s3Service.deleteObjects(keysToDelete);
        }
    }

    /**
     * Removes segments that have not been registered (lastSeen updated) for more than {@link #STALE_SEGMENTS_DAYS} days from their segment zip files, and compacts the remaining segments so that the
     * zip files are filled up to max entries again. The cleanup only runs once the number of stale segments exceeds {@link #STALE_SEGMENTS_THRESHOLD}, so that at least one full zip can be freed.
     */
    public void cleanupSegments() {
        OffsetDateTime cutoff = DateTimeUtil.now().minusDays(STALE_SEGMENTS_DAYS);
        int staleCount = preloadedSegmentProfileRepository.countByLastSeenBefore(cutoff);
        if (staleCount <= STALE_SEGMENTS_THRESHOLD) {
            log.debug("Segment cleanup skipped: only {} stale segments (threshold {})", staleCount, STALE_SEGMENTS_THRESHOLD);
            return;
        }
        log.info("Segment cleanup started. staleCount={}", staleCount);

        Map<Integer, List<PreloadedSegmentProfileEntity>> stalePreloadedSegments = findStalePreloadedSegments(cutoff);

        List<PreloadedSegmentProfileEntity> fillerPreloadedSegments = preloadedSegmentProfileRepository.findByLastSeenAfterOrderByFileIdDesc(cutoff, Limit.of(staleCount));
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
            preloadedSegmentProfileRepository.saveAll(fillers);
            preloadedSegmentProfileRepository.deleteAll(entry.getValue());
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
        List<PreloadedSegmentProfileEntity> stale = preloadedSegmentProfileRepository.findAllByLastSeenBefore(cutoff);
        return stale.stream().filter(e -> e.getFileId() != null).collect(Collectors.groupingBy(PreloadedSegmentProfileEntity::getFileId));
    }

    private String buildSegmentZipName(Integer index) {
        return String.format("%s_%d.zip", SEGMENT_PREFIX, index);
    }

    private String buildSegmentEntryName(String id) {
        return DIR_SP + "SP_" + id + ".xml";
    }
}
