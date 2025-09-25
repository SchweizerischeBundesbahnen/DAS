
package ch.sbb.backend.preload;

import ch.sbb.backend.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.OTNIDComplexType;
import ch.sbb.backend.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.TrainCharacteristics;
import ch.sbb.backend.preload.xml.XmlHelper;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.s3.model.S3Object;

@Service
public class PreloadStorageService {

    private static final String DIR_JP = "jp";
    private static final String DIR_SP = "sp";
    private static final String DIR_TC = "tc";
    private static final String ZIP_DIR_JP = DIR_JP + "/";
    private static final String ZIP_DIR_SP = DIR_SP + "/";
    private static final String ZIP_DIR_TC = DIR_TC + "/";

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;

    // Konfigurierbarer Zeitstempel (z. B. Europe/Zurich)
    @Value("${preload.timestamp-zone}")
    private String timestampZone;

    // Cleanup-Retention in Stunden
    @Value("${preload.cleanup-retention-hours}")
    private int cleanupRetentionHours;

    // Konfigurierbarer Parent-Ordner für Temp-Verzeichnisse (Default: <system tmp>/das-preload)
    @Value("${preload.temp-parent:}")
    private String tempParent;

    // Präfix für Temp-Verzeichnisnamen (Default: run-)
    @Value("${preload.temp-prefix:run-}")
    private String tempPrefix;

    public PreloadStorageService(XmlHelper xmlHelper, S3Service s3Service) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
    }

    public void save(List<JourneyProfile> journeyProfiles,
        List<SegmentProfile> segmentProfiles,
        List<TrainCharacteristics> trainCharacteristics) {

        Path tempRoot = null;
        Path zipFile = null;

        try {
            // 1) Temp-Verzeichnisstruktur (konfigurierbarer Parent + Präfix)
            Path parent = resolveTempParent();
            Files.createDirectories(parent);
            tempRoot = Files.createTempDirectory(parent, tempPrefix); // z. B. /tmp/das-preload/run-123456

            Path jpDir = Files.createDirectories(tempRoot.resolve(DIR_JP));
            Path spDir = Files.createDirectories(tempRoot.resolve(DIR_SP));
            Path tcDir = Files.createDirectories(tempRoot.resolve(DIR_TC));

            // 2) XML-Dateien erzeugen (falls Listen nicht leer sind)
            writeJps(journeyProfiles, jpDir);
            writeSps(segmentProfiles, spDir);
            writeTcs(trainCharacteristics, tcDir);

            // 3) ZIP-Dateiname im ISO-Format (lokale Zone), Windows-safe (':' -> '-')
            ZonedDateTime now = ZonedDateTime.now(ZoneId.of(timestampZone)).withNano(0);
            String iso = DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(now); // 2025-01-19T12:20:00
            String zipName = iso.replace(':', '-') + ".zip"; // 2025-01-19T12-20-00.zip

            // 4) ZIP erzeugen (inkl. Ordner-Einträgen)
            zipFile = tempRoot.resolve(zipName);
            createZipWithFolders(tempRoot, zipFile);

            // 5) In S3 ins Bucket-Root hochladen
            s3Service.uploadFile(zipName, zipFile);
        } catch (Exception e) {
            throw new RuntimeException("Preload save failed", e);
        } finally {
            // 6) Temporäres Aufräumen (Best Effort)
            try {
                if (zipFile != null) Files.deleteIfExists(zipFile);
                if (tempRoot != null) {
                    try (var walk = Files.walk(tempRoot)) {
                        walk.sorted(Comparator.reverseOrder()).forEach(p -> {
                            try { Files.deleteIfExists(p); } catch (IOException ignore) {}
                        });
                    }
                }
            } catch (IOException ignore) {}
        }
    }

    public void cleanUp() {
        Instant threshold = Instant.now().minus(Duration.ofHours(cleanupRetentionHours));
        List<S3Object> objects = s3Service.listObjects("");
        for (S3Object obj : objects) {
            if (obj.key().endsWith(".zip") && obj.lastModified().isBefore(threshold)) {
                s3Service.deleteObject(obj.key());
            }
        }
    }

    private void writeJps(List<JourneyProfile> jps, Path dir) throws IOException {
        for (JourneyProfile jp : jps) {
            OTNIDComplexType otnid = jp.getTrainIdentification().getOTNID();
            // todo: version minor not required
            String filename = String.format("JP_%s_%s_%s_%s.xml",
                otnid.getTeltsiCompany(),
                otnid.getTeltsiOperationalTrainNumber(),
                otnid.getTeltsiStartDate(),
                jp.getJPVersion());
            writeXmlFile(jp, dir.resolve(filename));
        }
    }

    private void writeSps(List<SegmentProfile> sps, Path dir) throws IOException {
        for (SegmentProfile sp : sps) {
            // todo: version minor not required
            String filename = String.format("SP_%s_%s_%s_%s.xml",
                sp.getSPID(),
                sp.getSPVersionMajor(),
                sp.getSPVersionMinor(),
                sp.getSPZone().getIMID());
            writeXmlFile(sp, dir.resolve(filename));
        }
    }

    private void writeTcs(List<TrainCharacteristics> tcs, Path dir) throws IOException {
        for (TrainCharacteristics tc : tcs) {
            String filename = String.format("TC_%s_%s_%s_%s.xml",
                tc.getTCID(),
                tc.getTCVersionMajor(),
                tc.getTCVersionMinor(),
                tc.getTCRUID());
            writeXmlFile(tc, dir.resolve(filename));
        }
    }

    private void writeXmlFile(Object item, Path path) throws IOException {
        if (item == null) return;
        String xml = xmlHelper.toString(item);
        Files.writeString(path, xml, StandardCharsets.UTF_8, StandardOpenOption.CREATE_NEW);
    }

    private void createZipWithFolders(Path root, Path zipFile) throws IOException {
        try (OutputStream os = Files.newOutputStream(zipFile, StandardOpenOption.CREATE_NEW);
            ZipOutputStream zos = new ZipOutputStream(os)) {

            // Ordner-Einträge explizit hinzufügen (sichtbar im ZIP, auch wenn leer)
            addDirectoryEntry(zos, ZIP_DIR_JP);
            addDirectoryEntry(zos, ZIP_DIR_SP);
            addDirectoryEntry(zos, ZIP_DIR_TC);

            addFolderFiles(zos, root.resolve(DIR_JP), root);
            addFolderFiles(zos, root.resolve(DIR_SP), root);
            addFolderFiles(zos, root.resolve(DIR_TC), root);
        }
    }

    private void addDirectoryEntry(ZipOutputStream zos, String name) throws IOException {
        ZipEntry dirEntry = new ZipEntry(name);
        zos.putNextEntry(dirEntry);
        zos.closeEntry();
    }

    private void addFolderFiles(ZipOutputStream zos, Path folder, Path root) throws IOException {
        if (!Files.exists(folder)) return;
        try (var stream = Files.walk(folder)) {
            stream.filter(Files::isRegularFile).forEach(file -> {
                String entryName = root.relativize(file).toString().replace('\\', '/');
                try {
                    zos.putNextEntry(new ZipEntry(entryName));
                    Files.copy(file, zos);
                    zos.closeEntry();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });
        }
    }

    private Path resolveTempParent() {
        if (tempParent == null || tempParent.isBlank()) {
            // Default: <system tmp>/das-preload
            return Path.of(System.getProperty("java.io.tmpdir")).resolve("das-preload");
        }
        return Path.of(tempParent);
    }
}
