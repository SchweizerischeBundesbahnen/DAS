package ch.sbb.backend.preload;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import software.amazon.awssdk.services.s3.model.S3Object;

import java.nio.file.Paths;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;

@RestController
@Tag(name = "Preload", description = "API for preloading SFERA datas and S3 utilities.")
public class FileController {

    private final S3Service s3Service;
    private final PreloadStorageService preloadStorageService;

    public FileController(S3Service s3Service, PreloadStorageService preloadStorageService) {
        this.s3Service = s3Service;
        this.preloadStorageService = preloadStorageService;
    }

    @Value("${preload.s3Prefix:}")
    private String s3Prefix;

    // Bestehend: generischer Upload einer lokalen Datei nach S3
    @PostMapping("/upload")
    public ResponseEntity<String> uploadFile(@RequestParam String key, @RequestParam String filePath) {
        s3Service.uploadFile(key, Paths.get(filePath));
        return new ResponseEntity<>("Upload erfolgreich!", HttpStatus.OK);
    }

    // Bestehend: generischer Download aus S3 in lokalen Pfad
    @GetMapping("/download")
    public ResponseEntity<String> downloadFile(@RequestParam String key, @RequestParam String destinationPath) {
        s3Service.downloadFile(key, Paths.get(destinationPath));
        return new ResponseEntity<>("Download erfolgreich!", HttpStatus.OK);
    }

    // Neu: erzeugt leeres ZIP (jp/sp/tc) und lädt es nach S3 – ideal für Swagger-Test
    @PostMapping("/preload/save-empty")
    public ResponseEntity<String> preloadSaveEmpty() {
        preloadStorageService.save(List.of(), List.of(), List.of());
        return ResponseEntity.ok("Preload ZIP erzeugt und nach S3 hochgeladen (leer).");
    }

    // Neu: S3-Keys (ZIPs) unter Prefix anzeigen
    @GetMapping("/preload/list")
    public ResponseEntity<List<S3ObjectDto>> preloadList(@RequestParam(name = "prefix", required = false) String prefix) {
        String p = (prefix != null) ? prefix : (s3Prefix == null ? "" : s3Prefix);
        List<S3ObjectDto> out = s3Service.listObjects(p).stream()
            .filter(o -> o.key().endsWith(".zip"))
            .sorted(Comparator.comparing(S3Object::lastModified))
            .map(o -> new S3ObjectDto(o.key(), o.size(), o.lastModified()))
            .toList();
        return ResponseEntity.ok(out);
    }

    // Neu: ZIP direkt aus S3 herunterladen (Swagger -> Datei speichern)
    @GetMapping("/preload/download")
    public ResponseEntity<byte[]> preloadDownload(@RequestParam String key) {
        byte[] data = s3Service.getObjectBytes(key);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentLength(data.length);
        headers.setContentDisposition(ContentDisposition.attachment()
            .filename(key.contains("/") ? key.substring(key.lastIndexOf('/') + 1) : key)
            .build());
        return new ResponseEntity<>(data, headers, HttpStatus.OK);
    }

    // Neu: Cleanup auslösen (löscht alte ZIPs gemäss retentionHours)
    @PostMapping("/preload/cleanup")
    public ResponseEntity<String> preloadCleanup() {
        preloadStorageService.cleanUp();
        return ResponseEntity.ok("Cleanup ausgeführt.");
    }

    public record S3ObjectDto(String key, long size, Instant lastModified) {}
}
