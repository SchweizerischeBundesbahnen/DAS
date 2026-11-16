package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.OTNID;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class StorageService implements PreloadStore {

    public static final String ZIP_FILE_ENDING = ".zip";
    public static final String DIR_JP = "jp/";
    public static final String DIR_TC = "tc/";
    public static final DateTimeFormatter FILENAME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH-mm-ssX");

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;

    public StorageService(XmlHelper xmlHelper, S3Service s3Service) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
    }

    @Override
    public void save(Collection<JourneyProfile> journeyProfiles, Collection<TrainCharacteristics> trainCharacteristics) {
        log.info("Saving journeyProfiles={}, trainCharacteristics={}...", journeyProfiles.size(), trainCharacteristics.size());
        try (ZipWriter zip = new ZipWriter()) {
            writeJps(journeyProfiles, zip);
            writeTcs(trainCharacteristics, zip);
            s3Service.uploadZip(buildZipName(), zip.finish());
        } catch (Exception e) {
            throw new RuntimeException("Preload save failed", e);
        }
    }

    private String buildZipName() {
        return FILENAME_FORMATTER.format(DateTimeUtil.now().toInstant().atZone(ZoneOffset.UTC)) + ZIP_FILE_ENDING;
    }

    private void writeJps(Collection<JourneyProfile> jps, ZipWriter zip) throws IOException {
        for (JourneyProfile jp : jps) {
            OTNID otnid = jp.getTrainIdentification().getOTNID();
            String filename = String.format("JP_%s_%s_%s_%s.xml", otnid.getTeltsiCompany(), otnid.getTeltsiOperationalTrainNumber(), otnid.getTeltsiStartDate(), jp.getJPVersion());
            writeXmlEntry(zip, DIR_JP + filename, jp);
        }
    }

    private void writeTcs(Collection<TrainCharacteristics> tcs, ZipWriter zip) throws IOException {
        for (TrainCharacteristics tc : tcs) {
            String filename = String.format("TC_%s_%s_%s.xml", tc.getTCID(), tc.getTCVersionMajor(), tc.getTCVersionMinor());
            writeXmlEntry(zip, DIR_TC + filename, tc);
        }
    }

    private void writeXmlEntry(ZipWriter zip, String entryName, Object obj) throws IOException {
        if (obj == null) {
            return;
        }
        zip.write(entryName, xmlHelper.toString(obj).getBytes(StandardCharsets.UTF_8));
    }
}
