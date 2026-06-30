package ch.sbb.das.backend.preload.application;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.preload.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.preload.infrastructure.S3Service;
import ch.sbb.das.backend.preload.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.preload.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.preload.sfera.model.v0400.OTNID;
import ch.sbb.das.backend.preload.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.preload.sfera.model.v0400.TrainCharacteristics;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class StorageService {

    private static final String DIR_JP = "jp/";
    private static final String DIR_SP = "sp/";
    private static final String DIR_TC = "tc/";
    private static final String ZIP_FILE_ENDING = ".zip";
    private static final DateTimeFormatter FILENAME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH-mm-ssX");
    private static final String DUPLICATE_ENTRY_KEY = "duplicate entry";
    private static final int MAX_SEGMENTS_PER_ZIP = 1000;
    private static final String SEGMENT_PREFIX = "Segments";
    private static final int STALE_SEGMENTS_DAYS = 30;

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;
    private final PreloadedSegmentProfileRepository preloadedSegmentProfileRepository;

    public StorageService(XmlHelper xmlHelper, S3Service s3Service, PreloadedSegmentProfileRepository preloadedSegmentProfileRepository) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
        this.preloadedSegmentProfileRepository = preloadedSegmentProfileRepository;
    }

    public void save(Collection<JourneyProfile> journeyProfiles, Collection<SegmentProfile> segmentProfiles, Collection<TrainCharacteristics> trainCharacteristics) {
        try {
            saveSegments(segmentProfiles);

            String zipName = buildZipName();
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {

                writeJps(journeyProfiles, zos);
                writeTcs(trainCharacteristics, zos);
            }

            s3Service.uploadZip(zipName, baos.toByteArray());

        } catch (Exception e) {
            throw new RuntimeException("Preload save failed", e);
        }
    }

    private void saveSegments(Collection<SegmentProfile> segmentProfiles) {
        if (segmentProfiles == null || segmentProfiles.isEmpty()) {
            return;
        }
        try {
            int fileId = 1;
            int fileCount = 0;
            Optional<PreloadedSegmentProfileEntity> latestFile = preloadedSegmentProfileRepository.findFirstByOrderByFileIdDesc();
            if (latestFile.isPresent()) {
                fileId = latestFile.get().getFileId();
                fileCount = preloadedSegmentProfileRepository.countByFileId(fileId);
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
                        .spIdVersion(String.format("%s_%s_%s", sp.getSPID(), sp.getSPVersionMajor(), sp.getSPVersionMinor()))
                        .lastSeen(now)
                        .fileId(fileId)
                        .build());
                }

                fileCount += batch.size();
                index = end;

                preloadedSegmentProfileRepository.saveAll(toSave);
            }

        } catch (Exception e) {
            throw new RuntimeException("Preload saveSegments failed", e);
        }
    }

    private void writeSegmentsToZip(int fileIndex, Collection<SegmentProfile> segmentProfiles) throws IOException {
        String key = buildSegmentZipName(fileIndex);
        Optional<byte[]> existing = s3Service.downloadZip(key);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            copyExistingEntries(existing, zos);
            writeSps(segmentProfiles, zos);
        }

        s3Service.uploadZip(key, baos.toByteArray());
    }

    private String buildSegmentZipName(Integer index) {
        return String.format("%s_%d.zip", SEGMENT_PREFIX, index);
    }

    private String buildZipName() {
        return FILENAME_FORMATTER.format(DateTimeUtil.now().toInstant().atZone(ZoneOffset.UTC)) + ZIP_FILE_ENDING;
    }

    private void writeJps(Collection<JourneyProfile> jps, ZipOutputStream zos) throws IOException {
        for (JourneyProfile jp : jps) {
            OTNID otnid = jp.getTrainIdentification().getOTNID();
            String filename = String.format("JP_%s_%s_%s_%s.xml",
                otnid.getTeltsiCompany(),
                otnid.getTeltsiOperationalTrainNumber(),
                otnid.getTeltsiStartDate(),
                jp.getJPVersion());
            writeXmlEntry(zos, DIR_JP + filename, jp);
        }
    }

    private void writeSps(Collection<SegmentProfile> sps, ZipOutputStream zos) throws IOException {
        for (SegmentProfile sp : sps) {
            String filename = String.format("SP_%s_%s_%s.xml",
                sp.getSPID(),
                sp.getSPVersionMajor(),
                sp.getSPVersionMinor());
            writeXmlEntry(zos, DIR_SP + filename, sp);
        }
    }

    private void writeTcs(Collection<TrainCharacteristics> tcs, ZipOutputStream zos) throws IOException {
        for (TrainCharacteristics tc : tcs) {
            String filename = String.format("TC_%s_%s_%s.xml",
                tc.getTCID(),
                tc.getTCVersionMajor(),
                tc.getTCVersionMinor());
            writeXmlEntry(zos, DIR_TC + filename, tc);
        }
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
            })
            .toList();

        if (!keysToDelete.isEmpty()) {
            s3Service.deleteObjects(keysToDelete);
        }
    }

    /**
     * Removes segments that have not been registered (lastSeen updated) for more than {@link #STALE_SEGMENTS_DAYS} days from their segment zip files, and compacts the remaining segments so that the
     * zip files are filled up to {@link #MAX_SEGMENTS_PER_ZIP} entries again. The cleanup only runs once the number of stale segments exceeds {@link #MAX_SEGMENTS_PER_ZIP}, so that at least one full
     * zip can be freed.
     */
    public void cleanupSegments() {
        OffsetDateTime cutoff = DateTimeUtil.now().minusDays(STALE_SEGMENTS_DAYS);
        long staleCount = preloadedSegmentProfileRepository.countByLastSeenBefore(cutoff);
        if (staleCount <= MAX_SEGMENTS_PER_ZIP) {
            log.debug("Segment cleanup skipped: only {} stale segments (threshold {})", staleCount, MAX_SEGMENTS_PER_ZIP);
            return;
        }
        log.info("Segment cleanup started. staleCount={}", staleCount);

        try {
            List<PreloadedSegmentProfileEntity> stale = preloadedSegmentProfileRepository.findAllByLastSeenBefore(cutoff);

            // 1) Remove stale segments from their respective zip files
            Map<Integer, List<PreloadedSegmentProfileEntity>> staleByFile = stale.stream()
                .filter(e -> e.getFileId() != null)
                .collect(Collectors.groupingBy(PreloadedSegmentProfileEntity::getFileId));

            for (Map.Entry<Integer, List<PreloadedSegmentProfileEntity>> entry : staleByFile.entrySet()) {
                Set<String> entryNamesToRemove = entry.getValue().stream()
                    .map(e -> buildSegmentEntryName(e.getSpIdVersion()))
                    .collect(Collectors.toSet());
                rewriteZipExcluding(entry.getKey(), entryNamesToRemove);
            }
            preloadedSegmentProfileRepository.deleteAll(stale);

            // 2) Compact: fill lower zip files with segments pulled from the highest zip files
            compactSegmentZips();

            log.info("Segment cleanup finished. removed={}", stale.size());
        } catch (IOException e) {
            throw new RuntimeException("Segment cleanup failed", e);
        }
    }

    private void compactSegmentZips() throws IOException {
        int maxFile = preloadedSegmentProfileRepository.findFirstByOrderByFileIdDesc()
            .map(PreloadedSegmentProfileEntity::getFileId)
            .orElse(0);

        for (int target = 1; target < maxFile; target++) {
            int targetCount = preloadedSegmentProfileRepository.countByFileId(target);
            while (targetCount < MAX_SEGMENTS_PER_ZIP && target < maxFile) {
                int sourceCount = preloadedSegmentProfileRepository.countByFileId(maxFile);
                if (sourceCount == 0) {
                    deleteSegmentZip(maxFile);
                    maxFile--;
                    continue;
                }

                int needed = MAX_SEGMENTS_PER_ZIP - targetCount;
                int moveCount = Math.min(needed, sourceCount);
                List<PreloadedSegmentProfileEntity> moving = preloadedSegmentProfileRepository.findAllByFileId(maxFile)
                    .stream()
                    .limit(moveCount)
                    .toList();
                Set<String> movingEntryNames = moving.stream()
                    .map(e -> buildSegmentEntryName(e.getSpIdVersion()))
                    .collect(Collectors.toSet());

                Map<String, byte[]> movedBytes = extractEntries(maxFile, movingEntryNames);

                rewriteZipExcluding(maxFile, movingEntryNames);
                appendEntries(target, movedBytes);

                final int targetFile = target;
                moving.forEach(e -> e.setFileId(targetFile));
                preloadedSegmentProfileRepository.saveAll(moving);

                targetCount += moving.size();

                if (preloadedSegmentProfileRepository.countByFileId(maxFile) == 0) {
                    deleteSegmentZip(maxFile);
                    maxFile--;
                }
            }
        }
    }

    private void rewriteZipExcluding(int fileIndex, Set<String> entryNamesToRemove) throws IOException {
        String key = buildSegmentZipName(fileIndex);
        Optional<byte[]> existing = s3Service.downloadZip(key);
        if (existing.isEmpty()) {
            return;
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        int keptEntries = 0;
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8);
            ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(existing.get()), StandardCharsets.UTF_8)) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                if (entryNamesToRemove.contains(entry.getName())) {
                    continue;
                }
                zos.putNextEntry(new ZipEntry(entry.getName()));
                zis.transferTo(zos);
                zos.closeEntry();
                keptEntries++;
            }
        }

        if (keptEntries == 0) {
            deleteSegmentZip(fileIndex);
        } else {
            s3Service.uploadZip(key, baos.toByteArray());
        }
    }

    private Map<String, byte[]> extractEntries(int fileIndex, Set<String> entryNames) throws IOException {
        Map<String, byte[]> result = new HashMap<>();
        Optional<byte[]> existing = s3Service.downloadZip(buildSegmentZipName(fileIndex));
        if (existing.isEmpty()) {
            return result;
        }
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(existing.get()), StandardCharsets.UTF_8)) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                if (entryNames.contains(entry.getName())) {
                    result.put(entry.getName(), zis.readAllBytes());
                }
            }
        }
        return result;
    }

    private void appendEntries(int fileIndex, Map<String, byte[]> entriesToAdd) throws IOException {
        if (entriesToAdd.isEmpty()) {
            return;
        }
        String key = buildSegmentZipName(fileIndex);
        Optional<byte[]> existing = s3Service.downloadZip(key);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            copyExistingEntries(existing, zos);
            for (Map.Entry<String, byte[]> e : entriesToAdd.entrySet()) {
                zos.putNextEntry(new ZipEntry(e.getKey()));
                zos.write(e.getValue());
                zos.closeEntry();
            }
        }
        s3Service.uploadZip(key, baos.toByteArray());
    }

    private void copyExistingEntries(Optional<byte[]> existing, ZipOutputStream zos) throws IOException {
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

    private void deleteSegmentZip(int fileIndex) {
        s3Service.deleteObjects(List.of(buildSegmentZipName(fileIndex)));
    }

    private String buildSegmentEntryName(String id) {
        return DIR_SP + "SP_" + id + ".xml";
    }
}
