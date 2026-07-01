package ch.sbb.das.backend.preload.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.preload.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.preload.infrastructure.S3Service;
import ch.sbb.das.backend.preload.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.preload.infrastructure.xml.SferaMessagingConfig;
import ch.sbb.das.backend.preload.infrastructure.xml.XmlDateHelper;
import ch.sbb.das.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.preload.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.preload.sfera.model.v0400.OTNID;
import ch.sbb.das.backend.preload.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.preload.sfera.model.v0400.TrainIdentification;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest(classes = {StorageService.class, XmlHelper.class, SferaMessagingConfig.class})
@ActiveProfiles("test")
class StorageServiceTest {

    @MockitoBean
    S3Service s3Service;

    @MockitoBean
    PreloadedSegmentProfileRepository preloadedSegmentProfileRepository;

    @Autowired
    StorageService underTest;

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

    private static JourneyProfile createJp() {
        JourneyProfile journeyProfile = new JourneyProfile();

        TrainIdentification trainId = new TrainIdentification();
        OTNID otnid = new OTNID();
        otnid.setTeltsiCompany("9353");
        otnid.setTeltsiOperationalTrainNumber("234");
        otnid.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(LocalDate.of(2025, 10, 17)));
        trainId.setOTNID(otnid);
        journeyProfile.setTrainIdentification(trainId);
        journeyProfile.setJPVersion(2L);
        return journeyProfile;
    }

    private static SegmentProfile createSp(String id) {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID(id);
        sp.setSPVersionMajor("1");
        sp.setSPVersionMinor("0");
        return sp;
    }

    @Test
    void save_doesNotCreateEmptyDirectoriesWhenNoFiles() throws Exception {
        underTest.save(Set.of(), Set.of(), Set.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        String zipName = zipNameCaptor.getValue();
        byte[] zipBytes = uploadDataCaptor.getValue();

        List<String> entries = listZipEntries(zipBytes);

        assertThat(zipName).endsWith(".zip");
        assertThat(entries).isEmpty();
    }

    @Test
    void save_createsZipWithOneJp() throws Exception {
        underTest.save(Set.of(createJp()), Set.of(), Set.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        String zipName = zipNameCaptor.getValue();
        byte[] zipBytes = uploadDataCaptor.getValue();

        List<String> entries = listZipEntries(zipBytes);

        assertThat(zipName).endsWith(".zip");
        assertThat(entries).containsExactly("jp/JP_9353_234_2025-10-17_2.xml");
    }

    @Test
    void save_ignoreDuplicateEntries() throws Exception {
        underTest.save(Set.of(createJp(), createJp()), Set.of(), Set.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        String zipName = zipNameCaptor.getValue();
        byte[] zipBytes = uploadDataCaptor.getValue();

        List<String> entries = listZipEntries(zipBytes);

        assertThat(zipName).endsWith(".zip");
        assertThat(entries).containsExactly("jp/JP_9353_234_2025-10-17_2.xml");
    }

    @Test
    void save_savesSegmentsToNewZipWhenNoPreviousFile() throws Exception {
        when(preloadedSegmentProfileRepository.findFirstByOrderByFileIdDesc()).thenReturn(Optional.empty());

        underTest.save(Set.of(), List.of(createSp("SP-1")), Set.of());

        // segments zip + jp zip
        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(2)).uploadZip(keyCaptor.capture(), dataCaptor.capture());

        int segIdx = keyCaptor.getAllValues().indexOf("Segments_1.zip");
        assertThat(segIdx).isGreaterThanOrEqualTo(0);

        List<String> entries = listZipEntries(dataCaptor.getAllValues().get(segIdx));
        assertThat(entries).containsExactly("sp/SP_SP-1_1_0.xml");

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<PreloadedSegmentProfileEntity>> entityCaptor = ArgumentCaptor.forClass(List.class);
        verify(preloadedSegmentProfileRepository, times(1)).saveAll(entityCaptor.capture());
        assertThat(entityCaptor.getValue())
            .singleElement()
            .satisfies(e -> {
                assertThat(e.getSpIdVersion()).isEqualTo("SP-1_1_0");
                assertThat(e.getFileId()).isEqualTo(1);
                assertThat(e.getLastSeen()).isNotNull();
            });
    }

    @Test
    void save_extendsExistingZipFromS3() throws Exception {
        PreloadedSegmentProfileEntity latest = PreloadedSegmentProfileEntity.builder()
            .spIdVersion("OLD_1_0").fileId(2).lastSeen(OffsetDateTime.now()).build();
        when(preloadedSegmentProfileRepository.findFirstByOrderByFileIdDesc()).thenReturn(Optional.of(latest));
        when(preloadedSegmentProfileRepository.countByFileId(2)).thenReturn(5);

        byte[] existingZip = buildZipWith("sp/SP_OLD_1_0.xml");
        when(s3Service.downloadZip("Segments_2.zip")).thenReturn(Optional.of(existingZip));

        underTest.save(Set.of(), List.of(createSp("NEW-1")), Set.of());

        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service).uploadZip(eq("Segments_2.zip"), dataCaptor.capture());

        List<String> entries = listZipEntries(dataCaptor.getValue());
        assertThat(entries).containsExactlyInAnyOrder("sp/SP_OLD_1_0.xml", "sp/SP_NEW-1_1_0.xml");
    }

    @Test
    void save_splitsSegmentsAcrossZipsWhenLimitReached() throws Exception {
        PreloadedSegmentProfileEntity latest = PreloadedSegmentProfileEntity.builder()
            .spIdVersion("X_1_0").fileId(2).lastSeen(OffsetDateTime.now()).build();
        when(preloadedSegmentProfileRepository.findFirstByOrderByFileIdDesc()).thenReturn(Optional.of(latest));
        when(preloadedSegmentProfileRepository.countByFileId(2)).thenReturn(999);
        when(s3Service.downloadZip(any())).thenReturn(Optional.empty());

        underTest.save(Set.of(), List.of(createSp("A"), createSp("B"), createSp("C")), Set.of());

        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(3)).uploadZip(keyCaptor.capture(), dataCaptor.capture());

        int idxFile2 = keyCaptor.getAllValues().indexOf("Segments_2.zip");
        int idxFile3 = keyCaptor.getAllValues().indexOf("Segments_3.zip");
        assertThat(idxFile2).isGreaterThanOrEqualTo(0);
        assertThat(idxFile3).isGreaterThanOrEqualTo(0);

        assertThat(listZipEntries(dataCaptor.getAllValues().get(idxFile2)))
            .containsExactly("sp/SP_A_1_0.xml");
        assertThat(listZipEntries(dataCaptor.getAllValues().get(idxFile3)))
            .containsExactlyInAnyOrder("sp/SP_B_1_0.xml", "sp/SP_C_1_0.xml");

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<PreloadedSegmentProfileEntity>> entityCaptor = ArgumentCaptor.forClass(List.class);
        verify(preloadedSegmentProfileRepository, times(2)).saveAll(entityCaptor.capture());

        List<List<PreloadedSegmentProfileEntity>> savedBatches = entityCaptor.getAllValues();
        assertThat(savedBatches.get(0)).hasSize(1).allSatisfy(e -> assertThat(e.getFileId()).isEqualTo(2));
        assertThat(savedBatches.get(1)).hasSize(2).allSatisfy(e -> assertThat(e.getFileId()).isEqualTo(3));
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
}

