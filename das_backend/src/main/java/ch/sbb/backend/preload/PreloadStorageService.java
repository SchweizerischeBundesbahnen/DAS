package ch.sbb.backend.preload;

import ch.sbb.backend.preload.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0201.OTNIDComplexType;
import ch.sbb.backend.preload.sfera.model.v0201.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0201.TrainCharacteristics;
import ch.sbb.backend.preload.xml.XmlHelper;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.springframework.stereotype.Service;

@Service
public class PreloadStorageService {

    private static final String DIR_JP = "jp/";
    private static final String DIR_SP = "sp/";
    private static final String DIR_TC = "tc/";

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
            writeXmlEntry(zos, DIR_JP + filename, jp);
        }
    }

    private void writeSps(List<SegmentProfile> sps, ZipOutputStream zos) throws IOException {
        for (SegmentProfile sp : sps) {
            String filename = String.format("SP_%s_%s_%s.xml",
                sp.getSPID(),
                sp.getSPVersionMajor(),
                sp.getSPVersionMinor());
            writeXmlEntry(zos, DIR_SP + filename, sp);
        }
    }

    private void writeTcs(List<TrainCharacteristics> tcs, ZipOutputStream zos) throws IOException {
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
}
