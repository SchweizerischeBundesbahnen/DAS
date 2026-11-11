package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.PreloadedSegmentProfileRepository;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.PreloadedSegmentProfileEntity;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.NSPListComplexType;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.NetworkSpecificParameter;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPAreas;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPZone;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TAFTAPLocation;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class SegmentProfileStoreTest {

    @Mock
    private XmlHelper xmlHelper;

    @Mock
    private S3Service s3Service;

    @Mock
    private PreloadedSegmentProfileRepository repository;

    @Captor
    private ArgumentCaptor<List<PreloadedSegmentProfileEntity>> savedEntities;

    @Captor
    private ArgumentCaptor<Set<String>> touchedIdVersions;

    private SegmentProfileStore underTest;

    @BeforeEach
    void setUp() {
        underTest = new SegmentProfileStore(xmlHelper, s3Service, repository);
    }

    @Test
    void missing_returnsTheReferencedSpsTheStoreDoesNotHoldAndKeepsTheKnownOnesAndTheirLocalRegulationSpsAlive() {
        SegmentProfileIdentification known = spId("SP_1");
        SegmentProfileIdentification unknown = spId("SP_2");
        when(repository.findAllBySpIdVersionIn(Set.of("SP_1_1_0", "SP_2_1_0"))).thenReturn(List.of(
            PreloadedSegmentProfileEntity.builder().spIdVersion("SP_1_1_0").relatedLrSpIdVersions(List.of("LR_1_DE_0", "LR_1_FR_0")).build()));

        Set<SegmentProfileIdentification> missing = underTest.missing(Set.of(known, unknown));

        assertThat(missing).containsExactly(unknown);
        verify(repository, times(2)).updateLastSeenBySpIdVersion(any(OffsetDateTime.class), touchedIdVersions.capture());
        assertThat(touchedIdVersions.getAllValues()).containsExactlyInAnyOrder(Set.of("SP_1_1_0"), Set.of("LR_1_DE_0", "LR_1_FR_0"));
    }

    @Test
    void missing_whenNothingIsReferenced_returnsNothingWithoutTouchingTheIndex() {
        assertThat(underTest.missing(Set.of())).isEmpty();

        verifyNoInteractions(repository);
    }

    @Test
    void save_savesSegmentsToNewZipWhenNoPreviousFile() throws Exception {
        givenXml();
        when(repository.findMaxFileId()).thenReturn(Optional.empty());

        underTest.save(List.of(createSp("SP-1")));

        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service).uploadZip(eq("Segments_1.zip"), dataCaptor.capture());
        assertThat(listZipEntries(dataCaptor.getValue())).containsExactly("sp/SP_SP-1_1_0.xml");

        verify(repository).saveAll(savedEntities.capture());
        assertThat(savedEntities.getValue())
            .singleElement()
            .satisfies(e -> {
                assertThat(e.getSpIdVersion()).isEqualTo("SP-1_1_0");
                assertThat(e.getFileId()).isEqualTo(1);
                assertThat(e.getLastSeen()).isNotNull();
                assertThat(e.getRelatedLrSpIdVersions()).isEmpty();
            });
    }

    @Test
    void save_persistsRelatedLocalRegulationSpIdVersionsForReferencingSp() {
        givenXml();
        when(repository.findMaxFileId()).thenReturn(Optional.empty());

        underTest.save(List.of(createSpWithLocalRegulations("SP-1", "LR_1;LR_2")));

        verify(repository).saveAll(savedEntities.capture());
        assertThat(savedEntities.getValue())
            .singleElement()
            .satisfies(e -> {
                assertThat(e.getSpIdVersion()).isEqualTo("SP-1_1_0");
                assertThat(e.getRelatedLrSpIdVersions())
                    .containsExactly("LR_1_DE_0", "LR_1_FR_0", "LR_1_IT_0", "LR_2_DE_0", "LR_2_FR_0", "LR_2_IT_0");
            });
    }

    @Test
    void save_extendsExistingZipFromS3() throws Exception {
        givenXml();
        when(repository.findMaxFileId()).thenReturn(Optional.of(2));
        when(repository.countByFileId(2)).thenReturn(5);
        when(s3Service.downloadZip("Segments_2.zip")).thenReturn(Optional.of(buildZipWith("sp/SP_OLD_1_0.xml")));

        underTest.save(List.of(createSp("NEW-1")));

        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service).uploadZip(eq("Segments_2.zip"), dataCaptor.capture());
        assertThat(listZipEntries(dataCaptor.getValue())).containsExactlyInAnyOrder("sp/SP_OLD_1_0.xml", "sp/SP_NEW-1_1_0.xml");
    }

    @Test
    void save_splitsSegmentsAcrossZipsWhenLimitReached() throws Exception {
        givenXml();
        when(repository.findMaxFileId()).thenReturn(Optional.of(2));
        when(repository.countByFileId(2)).thenReturn(999);
        when(s3Service.downloadZip(any())).thenReturn(Optional.empty());

        underTest.save(List.of(createSp("A"), createSp("B"), createSp("C")));

        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(2)).uploadZip(keyCaptor.capture(), dataCaptor.capture());
        assertThat(keyCaptor.getAllValues()).containsExactly("Segments_2.zip", "Segments_3.zip");
        assertThat(listZipEntries(dataCaptor.getAllValues().get(0))).containsExactly("sp/SP_A_1_0.xml");
        assertThat(listZipEntries(dataCaptor.getAllValues().get(1))).containsExactlyInAnyOrder("sp/SP_B_1_0.xml", "sp/SP_C_1_0.xml");

        verify(repository, times(2)).saveAll(savedEntities.capture());
        assertThat(savedEntities.getAllValues().get(0)).hasSize(1).allSatisfy(e -> assertThat(e.getFileId()).isEqualTo(2));
        assertThat(savedEntities.getAllValues().get(1)).hasSize(2).allSatisfy(e -> assertThat(e.getFileId()).isEqualTo(3));
    }

    @Test
    void compact_skipsWhenStaleCountBelowThreshold() {
        when(repository.countByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(500);

        underTest.compact();

        verify(repository, never()).findAllByLastSeenBefore(any());
        verify(s3Service, never()).downloadZip(any());
    }

    @Test
    void compact_removesStaleSegmentsAndReplacesWithFillers() throws Exception {
        when(repository.countByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(1001);
        List<PreloadedSegmentProfileEntity> stale = List.of(
            PreloadedSegmentProfileEntity.builder().spIdVersion("STALE_A_1_0").fileId(1).build(),
            PreloadedSegmentProfileEntity.builder().spIdVersion("STALE_B_1_0").fileId(1).build());
        when(repository.findAllByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(stale);
        PreloadedSegmentProfileEntity fillerA = PreloadedSegmentProfileEntity.builder().spIdVersion("FRESH_A_1_0").fileId(2).build();
        PreloadedSegmentProfileEntity fillerB = PreloadedSegmentProfileEntity.builder().spIdVersion("FRESH_B_1_0").fileId(2).build();
        when(repository.findByLastSeenAfterOrderByFileIdDesc(any(OffsetDateTime.class), any())).thenReturn(List.of(fillerA, fillerB));
        when(s3Service.downloadZip("Segments_1.zip")).thenReturn(Optional.of(buildZipWith("sp/SP_STALE_A_1_0.xml", "sp/SP_STALE_B_1_0.xml", "sp/SP_KEEP_1_0.xml")));
        when(s3Service.downloadZip("Segments_2.zip")).thenReturn(Optional.of(buildZipWith("sp/SP_FRESH_A_1_0.xml", "sp/SP_FRESH_B_1_0.xml")));

        underTest.compact();

        verify(repository).deleteAll(stale);
        verify(repository).saveAll(savedEntities.capture());
        assertThat(savedEntities.getValue()).hasSize(2).allSatisfy(e -> assertThat(e.getFileId()).isEqualTo(1));

        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, atLeastOnce()).uploadZip(keyCaptor.capture(), dataCaptor.capture());
        int idxFile1 = keyCaptor.getAllValues().indexOf("Segments_1.zip");
        assertThat(idxFile1).isGreaterThanOrEqualTo(0);
        assertThat(listZipEntries(dataCaptor.getAllValues().get(idxFile1)))
            .containsExactlyInAnyOrder("sp/SP_KEEP_1_0.xml", "sp/SP_FRESH_A_1_0.xml", "sp/SP_FRESH_B_1_0.xml");
        verify(s3Service).deleteObjects(List.of("Segments_2.zip"));
    }

    @Test
    void compact_evictsStaleLocalRegulationSps() throws Exception {
        when(repository.countByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(1001);
        List<PreloadedSegmentProfileEntity> stale = List.of(
            PreloadedSegmentProfileEntity.builder().spIdVersion("SP_1_1").fileId(1).build(),
            PreloadedSegmentProfileEntity.builder().spIdVersion("LR_1_DE_0").fileId(1).build());
        when(repository.findAllByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(stale);
        PreloadedSegmentProfileEntity fillerA = PreloadedSegmentProfileEntity.builder().spIdVersion("FRESH_A_1_0").fileId(2).build();
        PreloadedSegmentProfileEntity fillerB = PreloadedSegmentProfileEntity.builder().spIdVersion("FRESH_B_1_0").fileId(2).build();
        when(repository.findByLastSeenAfterOrderByFileIdDesc(any(OffsetDateTime.class), any())).thenReturn(List.of(fillerA, fillerB));
        when(s3Service.downloadZip("Segments_1.zip")).thenReturn(Optional.of(buildZipWith("sp/SP_SP_1_1.xml", "sp/SP_LR_1_DE_0.xml", "sp/SP_KEEP_1_0.xml")));
        when(s3Service.downloadZip("Segments_2.zip")).thenReturn(Optional.of(buildZipWith("sp/SP_FRESH_A_1_0.xml", "sp/SP_FRESH_B_1_0.xml")));

        underTest.compact();

        verify(repository).deleteAll(stale);
        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, atLeastOnce()).uploadZip(keyCaptor.capture(), dataCaptor.capture());
        int idxFile1 = keyCaptor.getAllValues().indexOf("Segments_1.zip");
        assertThat(idxFile1).isGreaterThanOrEqualTo(0);
        assertThat(listZipEntries(dataCaptor.getAllValues().get(idxFile1)))
            .doesNotContain("sp/SP_LR_1_DE_0.xml", "sp/SP_SP_1_1.xml")
            .containsExactlyInAnyOrder("sp/SP_KEEP_1_0.xml", "sp/SP_FRESH_A_1_0.xml", "sp/SP_FRESH_B_1_0.xml");
    }

    @Test
    void compact_compactsEightZipsIntoSeven() throws Exception {
        when(repository.countByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(1001);
        List<PreloadedSegmentProfileEntity> stale = new ArrayList<>();
        for (int f = 1; f <= 7; f++) {
            stale.add(PreloadedSegmentProfileEntity.builder().spIdVersion("STALE_F" + f + "_1_0").fileId(f).build());
        }
        when(repository.findAllByLastSeenBefore(any(OffsetDateTime.class))).thenReturn(stale);
        List<PreloadedSegmentProfileEntity> fillers = new ArrayList<>();
        for (int i = 1; i <= 7; i++) {
            fillers.add(PreloadedSegmentProfileEntity.builder().spIdVersion("FILLER_" + i + "_1_0").fileId(8).build());
        }
        when(repository.findByLastSeenAfterOrderByFileIdDesc(any(OffsetDateTime.class), any())).thenReturn(fillers);
        for (int f = 1; f <= 7; f++) {
            when(s3Service.downloadZip("Segments_" + f + ".zip")).thenReturn(Optional.of(
                buildZipWith("sp/SP_STALE_F" + f + "_1_0.xml", "sp/SP_KEEP_" + f + "A_1_0.xml", "sp/SP_KEEP_" + f + "B_1_0.xml")));
        }
        String[] file8Entries = new String[7];
        for (int i = 1; i <= 7; i++) {
            file8Entries[i - 1] = "sp/SP_FILLER_" + i + "_1_0.xml";
        }
        when(s3Service.downloadZip("Segments_8.zip")).thenReturn(Optional.of(buildZipWith(file8Entries)));

        underTest.compact();

        ArgumentCaptor<List<PreloadedSegmentProfileEntity>> deleteCaptor = ArgumentCaptor.captor();
        verify(repository, times(7)).deleteAll(deleteCaptor.capture());
        assertThat(deleteCaptor.getAllValues().stream().flatMap(List::stream).toList()).containsExactlyInAnyOrderElementsOf(stale);

        ArgumentCaptor<String> keyCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> dataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, atLeastOnce()).uploadZip(keyCaptor.capture(), dataCaptor.capture());
        for (int f = 1; f <= 7; f++) {
            String expectedKey = "Segments_" + f + ".zip";
            int idx = keyCaptor.getAllValues().indexOf(expectedKey);
            assertThat(idx).as("Expected upload for " + expectedKey).isGreaterThanOrEqualTo(0);
            assertThat(listZipEntries(dataCaptor.getAllValues().get(idx))).as("Entries in " + expectedKey)
                .contains("sp/SP_KEEP_" + f + "A_1_0.xml", "sp/SP_KEEP_" + f + "B_1_0.xml")
                .hasSize(3)
                .doesNotContain("sp/SP_STALE_F" + f + "_1_0.xml");
        }
        verify(s3Service).deleteObjects(List.of("Segments_8.zip"));

        verify(repository, times(7)).saveAll(savedEntities.capture());
        List<PreloadedSegmentProfileEntity> allSaved = savedEntities.getAllValues().stream().flatMap(List::stream).toList();
        assertThat(allSaved).hasSize(7).allSatisfy(saved -> assertThat(saved.getFileId()).isBetween(1, 7));
    }

    private void givenXml() {
        when(xmlHelper.toString(any())).thenReturn("<SegmentProfile/>");
    }

    private static SegmentProfileIdentification spId(String id) {
        return new SegmentProfileIdentification(id, "1", "0", "0085", null);
    }

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

    private static SegmentProfile createSp(String id) {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID(id);
        sp.setSPVersionMajor("1");
        sp.setSPVersionMinor("0");
        SPZone zone = new SPZone();
        zone.setIMID("0085");
        sp.setSPZone(zone);
        return sp;
    }

    private static SegmentProfile createSpWithLocalRegulations(String id, String languageNeutralTree) {
        SegmentProfile sp = createSp(id);
        SPAreas areas = new SPAreas();
        TAFTAPLocation location = new TAFTAPLocation();
        NSPListComplexType nsp = new NSPListComplexType();
        nsp.setNSPGroupName("localRegulations");
        NetworkSpecificParameter param = new NetworkSpecificParameter();
        param.setName("languageNeutralTree");
        param.setValue(languageNeutralTree);
        nsp.getNetworkSpecificParameters().add(param);
        location.getTAFTAPLocationNSPs().add(nsp);
        areas.getTAFTAPLocations().add(location);
        sp.setSPAreas(areas);
        return sp;
    }
}
