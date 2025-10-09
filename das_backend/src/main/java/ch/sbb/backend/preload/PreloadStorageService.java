
package ch.sbb.backend.preload;

import ch.sbb.backend.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.OTNIDComplexType;
import ch.sbb.backend.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.TrainCharacteristics;
import ch.sbb.backend.preload.xml.XmlHelper;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service
public class PreloadStorageService {

    private static final String DIR_JP = "jp";
    private static final String DIR_SP = "sp";
    private static final String DIR_TC = "tc";
    private static final String ZIP_DIR_JP = DIR_JP + "/";
    private static final String ZIP_DIR_SP = DIR_SP + "/";
    private static final String ZIP_DIR_TC = DIR_TC + "/";

    private static final ZoneId ZONE_BERN = ZoneId.of("Europe/Zurich");
    private static final DateTimeFormatter FILENAME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH-mm-ssXX");

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;

    public PreloadStorageService(XmlHelper xmlHelper, S3Service s3Service) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
    }

    public void save(List<JourneyProfile> journeyProfiles,
        List<SegmentProfile> segmentProfiles,
        List<TrainCharacteristics> trainCharacteristics) {

        try {
            String zipName = buildZipName();

            ByteArrayOutputStream baos = new ByteArrayOutputStream(64 * 1024);
            try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {

                addDirectoryEntry(zos, ZIP_DIR_JP);
                addDirectoryEntry(zos, ZIP_DIR_SP);
                addDirectoryEntry(zos, ZIP_DIR_TC);

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
        OffsetDateTime nowOffset = OffsetDateTime.now(ZONE_BERN).withNano(0);
        return FILENAME_FORMATTER.format(nowOffset) + ".zip";
    }

    private void writeJps(List<JourneyProfile> jps, ZipOutputStream zos) throws IOException {
        for (JourneyProfile jp : jps) {
            OTNIDComplexType otnid = jp.getTrainIdentification().getOTNID();
            String filename = String.format("JP_%s_%s_%s_%s.xml",
                otnid.getTeltsiCompany(),
                otnid.getTeltsiOperationalTrainNumber(),
                otnid.getTeltsiStartDate(),
                jp.getJPVersion());
            writeXmlEntry(zos, filename, jp);
        }
    }

    private void writeSps(List<SegmentProfile> sps, ZipOutputStream zos) throws IOException {
        for (SegmentProfile sp : sps) {
            String filename = String.format("SP_%s_%s_%s.xml",
                sp.getSPID(),
                sp.getSPVersionMajor(),
                sp.getSPVersionMinor());
            writeXmlEntry(zos,  filename, sp);
        }
    }

    private void writeTcs(List<TrainCharacteristics> tcs, ZipOutputStream zos) throws IOException {
        for (TrainCharacteristics tc : tcs) {
            String filename = String.format("TC_%s_%s_%s.xml",
                tc.getTCID(),
                tc.getTCVersionMajor(),
                tc.getTCVersionMinor());
            writeXmlEntry(zos, filename, tc);
        }
    }

    private void writeXmlEntry(ZipOutputStream zos, String entryName, Object obj) throws IOException {
        if (obj == null) return;
        String xml = xmlHelper.toString(obj);
        ZipEntry entry = new ZipEntry(entryName);
        zos.putNextEntry(entry);
        zos.write(xml.getBytes(StandardCharsets.UTF_8));
        zos.closeEntry();
    }

    private void addDirectoryEntry(ZipOutputStream zos, String name) throws IOException {
        ZipEntry dirEntry = new ZipEntry(name);
        zos.putNextEntry(dirEntry);
        zos.closeEntry();
    }
}
