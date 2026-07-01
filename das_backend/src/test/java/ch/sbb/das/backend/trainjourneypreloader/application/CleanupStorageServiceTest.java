package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest(classes = {CleanupStorageService.class})
@ActiveProfiles("test")
class CleanupStorageServiceTest {

    @MockitoBean
    S3Service s3Service;

    @MockitoBean
    PreloadedSegmentProfileRepository preloadedSegmentProfileRepository;

    @Autowired
    CleanupStorageService underTest;

    private static List<String> listZipEntries(byte[] zipBytes) throws IOException {
        List<String> names = new ArrayList<>();
        try (ZipInputStream zis = new ZipInputStream(new ByteArrayInputStream(zipBytes))) {
            ZipEntry e;
            while ((e = zis.getNextEntry()) != null) {
                names.add(e.getName());
            }
        }
        return names;
    }

    private static byte[] buildZipWith(String... entryNames) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos, StandardCharsets.UTF_8)) {
            for (String name : entryNames) {
                zos.putNextEntry(new ZipEntry(name));
                zos.write(("<dummy/>").getBytes(StandardCharsets.UTF_8));
                zos.closeEntry();
            }
        }
        return baos.toByteArray();
    }

    @Test
    void deleteAllBefore() {
        when(s3Service.listObjects()).thenReturn(List.of("2026-02-20T08-00-00Z.zip", "2026-02-20T05-00-20Z.zip"));

        underTest.deleteAllBefore(OffsetDateTime.of(2026, 2, 20, 6, 1, 0, 0, ZoneOffset.ofHours(1)));

        verify(s3Service, times(1)).deleteObjects(List.of("2026-02-20T05-00-20Z.zip"));
    }

    @Test
    void deleteAllBefore_withInvalidFiles() {
        when(s3Service.listObjects()).thenReturn(List.of("myInvalidFile.das", "2026-01-01T18-21-49Z.zip", "2026-99-01T18-21-49Z.zip", "2026-01-01X18-21-49.zip"));

        underTest.deleteAllBefore(OffsetDateTime.of(2026, 2, 1, 0, 0, 0, 0, ZoneOffset.ofHours(1)));

        verify(s3Service, times(1)).deleteObjects(List.of("2026-01-01T18-21-49Z.zip"));
    }

    @Test
    void deleteAllBefore_ignoresSegmentZips() {
        when(s3Service.listObjects()).thenReturn(List.of("Segments_1.zip", "2026-01-01T00-00-00Z.zip"));

        underTest.deleteAllBefore(OffsetDateTime.of(2026, 2, 1, 0, 0, 0, 0, ZoneOffset.UTC));

        verify(s3Service, times(1)).deleteObjects(List.of("2026-01-01T00-00-00Z.zip"));
    }

    @Test
    void cleanupSegments_skipsWhenStaleCountBelowThreshold() {
        when(preloadedSegmentProfileRepository.countByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(500);

        underTest.cleanupSegments();

        verify(preloadedSegmentProfileRepository, org.mockito.Mockito.never()).findAllByLastSeenBefore(any());
        verify(s3Service, org.mockito.Mockito.never()).downloadZip(any());
    }

    @Test
    void cleanupSegments_removesStaleSegmentsAndReplacesWithFillers() throws Exception {
        when(preloadedSegmentProfileRepository.countByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(1001);

        // 2 stale segments in file 1
        List<PreloadedSegmentProfileEntity> stale = List.of(
            PreloadedSegmentProfileEntity.builder().spIdVersion("STALE_A_1_0").fileId(1).build(),
            PreloadedSegmentProfileEntity.builder().spIdVersion("STALE_B_1_0").fileId(1).build()
        );
        when(preloadedSegmentProfileRepository.findAllByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(stale);

        // 2 filler segments from file 2
        PreloadedSegmentProfileEntity fillerA = PreloadedSegmentProfileEntity.builder().spIdVersion("FRESH_A_1_0").fileId(2).build();
        PreloadedSegmentProfileEntity fillerB = PreloadedSegmentProfileEntity.builder().spIdVersion("FRESH_B_1_0").fileId(2).build();
        when(preloadedSegmentProfileRepository.findByLastSeenAfterOrderByFileIdDesc(any(OffsetDateTime.class), any()))
            .thenReturn(List.of(fillerA, fillerB));

        // File 1 zip contains the 2 stale entries + 1 fresh entry that stays
        when(s3Service.downloadZip("Segments_1.zip")).thenReturn(Optional.of(
            buildZipWith("sp/SP_STALE_A_1_0.xml", "sp/SP_STALE_B_1_0.xml", "sp/SP_KEEP_1_0.xml")));

        // File 2 zip contains the 2 filler entries
        when(s3Service.downloadZip("Segments_2.zip")).thenReturn(Optional.of(
            buildZipWith("sp/SP_FRESH_A_1_0.xml", "sp/SP_FRESH_B_1_0.xml")));

        underTest.cleanupSegments();

        // Verify stale entities deleted from DB
        verify(preloadedSegmentProfileRepository).deleteAll(stale);

        // Verify fillers were saved with updated fileId
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<PreloadedSegmentProfileEntity>> saveCaptor = ArgumentCaptor.forClass(List.class);
        verify(preloadedSegmentProfileRepository).saveAll(saveCaptor.capture());
        assertThat(saveCaptor.getValue()).hasSize(2)
            .allSatisfy(e -> assertThat(e.getFileId()).isEqualTo(1));

        // Verify file 1 was rewritten: stale removed, fillers added, existing kept
        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, atLeastOnce()).uploadZip(keyCaptor.capture(), dataCaptor.capture());

        int idxFile1 = keyCaptor.getAllValues().indexOf("Segments_1.zip");
        assertThat(idxFile1).isGreaterThanOrEqualTo(0);
        assertThat(listZipEntries(dataCaptor.getAllValues().get(idxFile1)))
            .containsExactlyInAnyOrder("sp/SP_KEEP_1_0.xml", "sp/SP_FRESH_A_1_0.xml", "sp/SP_FRESH_B_1_0.xml");

        // Verify file 2 becomes empty after fillers removed -> deleted
        verify(s3Service).deleteObjects(List.of("Segments_2.zip"));
    }

    @Test
    void cleanupSegments_compactsEightZipsIntoSeven() throws Exception {
        int totalStale = 1001;
        when(preloadedSegmentProfileRepository.countByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(totalStale);

        // 1 stale per file (files 1-7)
        List<PreloadedSegmentProfileEntity> stale = new ArrayList<>();
        for (int f = 1; f <= 7; f++) {
            stale.add(PreloadedSegmentProfileEntity.builder().spIdVersion("STALE_F" + f + "_1_0").fileId(f).build());
        }
        when(preloadedSegmentProfileRepository.findAllByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(stale);

        // Fillers: 7 segments from file 8
        List<PreloadedSegmentProfileEntity> fillers = new ArrayList<>();
        for (int i = 1; i <= 7; i++) {
            fillers.add(PreloadedSegmentProfileEntity.builder().spIdVersion("FILLER_" + i + "_1_0").fileId(8).build());
        }
        when(preloadedSegmentProfileRepository.findByLastSeenAfterOrderByFileIdDesc(any(OffsetDateTime.class), any()))
            .thenReturn(fillers);

        // Each file 1-7 has: 1 stale entry + 2 fresh entries that stay
        for (int f = 1; f <= 7; f++) {
            when(s3Service.downloadZip("Segments_" + f + ".zip")).thenReturn(Optional.of(
                buildZipWith(
                    "sp/SP_STALE_F" + f + "_1_0.xml",
                    "sp/SP_KEEP_" + f + "A_1_0.xml",
                    "sp/SP_KEEP_" + f + "B_1_0.xml"
                )));
        }

        // File 8 has all 7 filler entries
        String[] file8Entries = new String[7];
        for (int i = 1; i <= 7; i++) {
            file8Entries[i - 1] = "sp/SP_FILLER_" + i + "_1_0.xml";
        }
        when(s3Service.downloadZip("Segments_8.zip")).thenReturn(Optional.of(buildZipWith(file8Entries)));

        underTest.cleanupSegments();

        // Verify all stale entries deleted from DB (one deleteAll call per file)
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<PreloadedSegmentProfileEntity>> deleteCaptor = ArgumentCaptor.forClass(List.class);
        verify(preloadedSegmentProfileRepository, times(7)).deleteAll(deleteCaptor.capture());
        List<PreloadedSegmentProfileEntity> allDeleted = deleteCaptor.getAllValues().stream()
            .flatMap(List::stream).toList();
        assertThat(allDeleted).containsExactlyInAnyOrderElementsOf(stale);

        // Verify uploads: files 1-7 should be rewritten (stale removed, filler added)
        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, atLeastOnce()).uploadZip(keyCaptor.capture(), dataCaptor.capture());

        for (int f = 1; f <= 7; f++) {
            String expectedKey = "Segments_" + f + ".zip";
            int idx = keyCaptor.getAllValues().indexOf(expectedKey);
            assertThat(idx).as("Expected upload for " + expectedKey).isGreaterThanOrEqualTo(0);

            List<String> entries = listZipEntries(dataCaptor.getAllValues().get(idx));
            assertThat(entries).as("Entries in " + expectedKey)
                .contains("sp/SP_KEEP_" + f + "A_1_0.xml", "sp/SP_KEEP_" + f + "B_1_0.xml")
                .hasSize(3)
                .doesNotContain("sp/SP_STALE_F" + f + "_1_0.xml");
        }

        // File 8 should be deleted (all fillers removed, zip is empty)
        verify(s3Service).deleteObjects(List.of("Segments_8.zip"));

        // Verify fillers were saved with updated fileIds (distributed across files 1-7)
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<PreloadedSegmentProfileEntity>> saveCaptor = ArgumentCaptor.forClass(List.class);
        verify(preloadedSegmentProfileRepository, times(7)).saveAll(saveCaptor.capture());
        List<PreloadedSegmentProfileEntity> allSaved = saveCaptor.getAllValues().stream()
            .flatMap(List::stream).toList();
        assertThat(allSaved).hasSize(7);

        // Each filler should be assigned to one of files 1-7
        for (PreloadedSegmentProfileEntity saved : allSaved) {
            assertThat(saved.getFileId()).isBetween(1, 7);
        }
    }
}
