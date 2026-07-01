package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.OTNID;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class StorageService {

    public static final String SEGMENT_PREFIX = "Segments";
    public static final String ZIP_FILE_ENDING = ".zip";
    public static final String DIR_JP = "jp/";
    public static final String DIR_SP = "sp/";
    public static final String DIR_TC = "tc/";
    public static final DateTimeFormatter FILENAME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH-mm-ssX");

    private static final String DUPLICATE_ENTRY_KEY = "duplicate entry";
    private static final int MAX_SEGMENTS_PER_ZIP = 1000;

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;
    private final PreloadedSegmentProfileRepository preloadedSegmentProfileRepository;

    public StorageService(XmlHelper xmlHelper, S3Service s3Service, PreloadedSegmentProfileRepository preloadedSegmentProfileRepository) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
        this.preloadedSegmentProfileRepository = preloadedSegmentProfileRepository;
    }

    public void save(Collection<JourneyProfile> journeyProfiles, Collection<SegmentProfile> segmentProfiles, Collection<TrainCharacteristics> trainCharacteristics) {
        log.info("Saving journeyProfiles={}, segmentProfiles={}, trainCharacteristics={}...", journeyProfiles.size(), segmentProfiles.size(), trainCharacteristics.size());
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
            Optional<Integer> latestFileId = preloadedSegmentProfileRepository.findMaxFileId();
            if (latestFileId.isPresent()) {
                fileId = latestFileId.get();
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
                    toSave.add(PreloadedSegmentProfileEntity.builder().spIdVersion(String.format("%s_%s_%s", sp.getSPID(), sp.getSPVersionMajor(), sp.getSPVersionMinor())).lastSeen(now).fileId(fileId)
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
            transferExistingEntries(existing, zos);
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
            String filename = String.format("JP_%s_%s_%s_%s.xml", otnid.getTeltsiCompany(), otnid.getTeltsiOperationalTrainNumber(), otnid.getTeltsiStartDate(), jp.getJPVersion());
            writeXmlEntry(zos, DIR_JP + filename, jp);
        }
    }

    private void writeSps(Collection<SegmentProfile> sps, ZipOutputStream zos) throws IOException {
        for (SegmentProfile sp : sps) {
            String filename = String.format("SP_%s_%s_%s.xml", sp.getSPID(), sp.getSPVersionMajor(), sp.getSPVersionMinor());
            writeXmlEntry(zos, DIR_SP + filename, sp);
        }
    }

    private void writeTcs(Collection<TrainCharacteristics> tcs, ZipOutputStream zos) throws IOException {
        for (TrainCharacteristics tc : tcs) {
            String filename = String.format("TC_%s_%s_%s.xml", tc.getTCID(), tc.getTCVersionMajor(), tc.getTCVersionMinor());
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
}
