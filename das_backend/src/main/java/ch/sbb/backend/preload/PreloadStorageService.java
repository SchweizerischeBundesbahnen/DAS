package ch.sbb.backend.preload;

import ch.sbb.backend.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.backend.adapters.sfera.model.v0201.TrainCharacteristics;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.s3.model.S3Object;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service
public class PreloadStorageService {

    private final XmlHelper xmlHelper;
    private final S3Service s3Service;

    @Value("${preload.s3Prefix:}")
    private String s3Prefix;

    @Value("${preload.retentionHours:24}")
    private int retentionHours;

    @Value("${preload.timestampZone:Europe/Zurich}")
    private String timestampZone;

    private static final DateTimeFormatter ZIP_NAME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm.ss");

    public PreloadStorageService(XmlHelper xmlHelper, S3Service s3Service) {
        this.xmlHelper = xmlHelper;
        this.s3Service = s3Service;
    }

    public void save(List<JourneyProfile> journeyProfiles, List<SegmentProfile> segmentProfiles, List<TrainCharacteristics> trainCharacteristics) {

        Path tempRoot = null;
        Path zipFile = null;

        try {
            // 1) Temp-Struktur
            tempRoot = Files.createTempDirectory("preload_");
            Path jpDir = Files.createDirectories(tempRoot.resolve("jp"));
            Path spDir = Files.createDirectories(tempRoot.resolve("sp"));
            Path tcDir = Files.createDirectories(tempRoot.resolve("tc"));

            // 2) XML-Dateien schreiben
            writeXmlFiles(journeyProfiles, jpDir, "jp");
            writeXmlFiles(segmentProfiles, spDir, "sp");
            writeXmlFiles(trainCharacteristics, tcDir, "tc");

            // 3) ZIP-Dateiname wie 2025-01-19T13:20.00.zip (Sekunden auf 00)
            ZonedDateTime now = ZonedDateTime.now(ZoneId.of(timestampZone))
                .withSecond(0).withNano(0);
            String zipName = ZIP_NAME_FMT.format(now) + ".zip";

            // 4) ZIP erzeugen
            zipFile = tempRoot.resolve(zipName);
            createZip(tempRoot, zipFile);

            // 5) Nach S3 hochladen
            String key = (s3Prefix == null || s3Prefix.isEmpty()) ? zipName : s3Prefix + zipName;
            s3Service.uploadFile(key, zipFile);
        } catch (Exception e) {
            throw new RuntimeException("Preload save failed", e);
        } finally {
            // 6) Lokale Temps aufräumen
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
        String prefix = (s3Prefix == null) ? "" : s3Prefix;
        Instant threshold = Instant.now().minus(Duration.ofHours(retentionHours));

        List<S3Object> objects = s3Service.listObjects(prefix);
        for (S3Object obj : objects) {
            String key = obj.key();
            if (!key.endsWith(".zip")) continue;
            if (obj.lastModified().isBefore(threshold)) {
                s3Service.deleteObject(key);
            }
        }
    }

    private <T> void writeXmlFiles(List<T> items, Path dir, String prefix) throws IOException {
        if (items == null || items.isEmpty()) return;
        AtomicInteger idx = new AtomicInteger(1);
        for (T item : items) {
            String xml = xmlHelper.toString(item);
            String filename = String.format("%s_%04d.xml", prefix, idx.getAndIncrement());
            Files.writeString(dir.resolve(filename), xml, StandardCharsets.UTF_8, StandardOpenOption.CREATE_NEW);
        }
    }

    private void createZip(Path root, Path zipFile) throws IOException {
        try (OutputStream os = Files.newOutputStream(zipFile, StandardOpenOption.CREATE_NEW);
            ZipOutputStream zos = new ZipOutputStream(os)) {

            addFolder(zos, root.resolve("jp"), root);
            addFolder(zos, root.resolve("sp"), root);
            addFolder(zos, root.resolve("tc"), root);
        }
    }

    private void addFolder(ZipOutputStream zos, Path folder, Path root) throws IOException {
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
}
