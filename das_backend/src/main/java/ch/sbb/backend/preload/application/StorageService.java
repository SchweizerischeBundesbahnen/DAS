package ch.sbb.backend.preload.application;

import ch.sbb.backend.preload.infrastructure.S3Service;
import ch.sbb.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.OTNID;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
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

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;

    public StorageService(XmlHelper xmlHelper, S3Service s3Service) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
    }

    public void save(Set<JourneyProfile> journeyProfiles, Set<SegmentProfile> segmentProfiles, Set<TrainCharacteristics> trainCharacteristics) {
        try {
            String zipName = buildZipName();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {

                writeJps(journeyProfiles, zos);
                writeSps(segmentProfiles, zos);
                writeTcs(trainCharacteristics, zos);
            }

            s3Service.uploadZip(zipName, baos.toByteArray());

        } catch (Exception e) {
            throw new RuntimeException("Preload save failed", e);
        }
    }

    private String buildZipName() {
        OffsetDateTime nowOffset = OffsetDateTime.now();
        return FILENAME_FORMATTER.format(nowOffset.toInstant().atZone(ZoneOffset.UTC)) + ZIP_FILE_ENDING;
    }

    private void writeJps(Set<JourneyProfile> jps, ZipOutputStream zos) throws IOException {
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

    private void writeSps(Set<SegmentProfile> sps, ZipOutputStream zos) throws IOException {
        for (SegmentProfile sp : sps) {
            String filename = String.format("SP_%s_%s_%s.xml",
                sp.getSPID(),
                sp.getSPVersionMajor(),
                sp.getSPVersionMinor());
            writeXmlEntry(zos, DIR_SP + filename, sp);
        }
    }

    private void writeTcs(Set<TrainCharacteristics> tcs, ZipOutputStream zos) throws IOException {
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
        zos.putNextEntry(entry);
        zos.write(xml.getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }

    void cleanUp(OffsetDateTime cutoffDate) {
        List<String> keysToDelete = s3Service.listObjects().stream()
            .filter(k -> k != null && k.endsWith(ZIP_FILE_ENDING))
            .filter(k -> {
                try {
                    String base = k.substring(0, k.length() - ZIP_FILE_ENDING.length());
                    OffsetDateTime ts = OffsetDateTime.parse(base, FILENAME_FORMATTER);
                    return ts.isBefore(cutoffDate);
                } catch (DateTimeParseException e) {
                    log.warn("CleanUp: Skipping zip file with unexpected name: {}", k);
                    return false;
                }
            })
            .toList();

        if (!keysToDelete.isEmpty()) {
            s3Service.deleteObjects(keysToDelete);
        }
    }
}
