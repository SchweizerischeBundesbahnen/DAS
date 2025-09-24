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

    private static final DateTimeFormatter ZIP_NAME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm.ss");
    private final XmlHelper xmlHelper;
    private final S3Service s3Service;
    @Value("${preload.s3Prefix:}")
    private String s3Prefix;
    @Value("${preload.retentionHours:24}")
    private int retentionHours;
    @Value("${preload.timestampZone:Europe/Zurich}")
    private String timestampZone;

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
            // 1) Temp-Verzeichnisstruktur
            tempRoot = Files.createTempDirectory("preload_");
            Path jpDir = Files.createDirectories(tempRoot.resolve("jp"));
            Path spDir = Files.createDirectories(tempRoot.resolve("sp"));
            Path tcDir = Files.createDirectories(tempRoot.resolve("tc"));


            // 2) XML-Dateien erzeugen (falls Listen nicht leer sind)
            writeJps(journeyProfiles, jpDir);
            writeSps(segmentProfiles, spDir);
            writeTcs(trainCharacteristics, tcDir);

            // 3) ZIP-Dateiname wie 2025-01-19T13:20.00.zip (Sekunden=00)
            ZonedDateTime now = ZonedDateTime.now(ZoneId.of(timestampZone))
                .withSecond(0).withNano(0);
            String zipName = ZIP_NAME_FMT.format(now) + ".zip";

            // 4) ZIP erzeugen (inkl. Ordner-Einträgen)
            zipFile = tempRoot.resolve(zipName);
            createZipWithFolders(tempRoot, zipFile);

            // 5) Nach S3 hochladen
            String key = (s3Prefix == null || s3Prefix.isEmpty()) ? zipName : s3Prefix + zipName;
            s3Service.uploadFile(key, zipFile);
        } catch (Exception e) {
            throw new RuntimeException("Preload save failed", e);
        } finally {
            // 6) Temporäres Aufräumen (Best Effort)
            try {
                if (zipFile != null) {
                    Files.deleteIfExists(zipFile);
                }
                if (tempRoot != null) {
                    try (var walk = Files.walk(tempRoot)) {
                        walk.sorted(Comparator.reverseOrder()).forEach(p -> {
                            try {
                                Files.deleteIfExists(p);
                            } catch (IOException ignore) {
                            }
                        });
                    }
                }
            } catch (IOException ignore) {
            }
        }
    }

    public void cleanUp() {
        String prefix = (s3Prefix == null) ? "" : s3Prefix;
        Instant threshold = Instant.now().minus(Duration.ofHours(retentionHours));

        List<S3Object> objects = s3Service.listObjects(prefix);
        for (S3Object obj : objects) {
            String key = obj.key();
            if (!key.endsWith(".zip")) {
                continue;
            }
            if (obj.lastModified().isBefore(threshold)) {
                s3Service.deleteObject(key);
            }
        }
    }

    private void writeJps(List<JourneyProfile> jps, Path dir) throws IOException {
        for (JourneyProfile jp : jps) {
            OTNIDComplexType otnid = jp.getTrainIdentification().getOTNID();
            // todo: version minor not required
            String filename = String.format("JP_%s_%s_%s_%s.xml", otnid.getTeltsiCompany(), otnid.getTeltsiOperationalTrainNumber(), otnid.getTeltsiStartDate(), jp.getJPVersion());
            writeXmlFile(jp, dir.resolve(filename));
        }
    }

    private void writeSps(List<SegmentProfile> sps, Path dir) throws IOException {
        for (SegmentProfile sp : sps) {
            // todo: version minor not required
            String filename = String.format("SP_%s_%s_%s_%s.xml", sp.getSPID(), sp.getSPVersionMajor(), sp.getSPVersionMinor(), sp.getSPZone().getIMID());
            writeXmlFile(sp, dir.resolve(filename));
        }
    }

    private void writeTcs(List<TrainCharacteristics> tcs, Path dir) throws IOException {
        for (TrainCharacteristics tc : tcs) {
            String filename = String.format("TC_%s_%s_%s_%s.xml", tc.getTCID(), tc.getTCVersionMajor(), tc.getTCVersionMinor(), tc.getTCRUID());
            writeXmlFile(tc, dir.resolve(filename));
        }
    }

    private void writeXmlFile(Object item, Path path) throws IOException {
        if (item == null) {
            return;
        }

        String xml = xmlHelper.toString(item);
        Files.writeString(path, xml, StandardCharsets.UTF_8, StandardOpenOption.CREATE_NEW);
    }

    private void createZipWithFolders(Path root, Path zipFile) throws IOException {
        try (OutputStream os = Files.newOutputStream(zipFile, StandardOpenOption.CREATE_NEW);
            ZipOutputStream zos = new ZipOutputStream(os)) {

            // Ordner-Einträge explizit hinzufügen (sichtbar im ZIP, auch wenn leer)
            addDirectoryEntry(zos, "jp/");
            addDirectoryEntry(zos, "sp/");
            addDirectoryEntry(zos, "tc/");

            addFolderFiles(zos, root.resolve("jp"), root);
            addFolderFiles(zos, root.resolve("sp"), root);
            addFolderFiles(zos, root.resolve("tc"), root);
        }
    }

    private void addDirectoryEntry(ZipOutputStream zos, String name) throws IOException {
        ZipEntry dirEntry = new ZipEntry(name);
        zos.putNextEntry(dirEntry);
        zos.closeEntry();
    }

    private void addFolderFiles(ZipOutputStream zos, Path folder, Path root) throws IOException {
        if (!Files.exists(folder)) {
            return;
        }
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
}