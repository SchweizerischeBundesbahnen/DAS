package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.SferaMessagingConfig;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlDateHelper;
import ch.sbb.das.backend.trainjourneypreloader.infrastructure.xml.XmlHelper;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.OTNID;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainIdentification;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
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

    @Test
    void save_doesNotCreateEmptyDirectoriesWhenNoFiles() throws Exception {
        underTest.save(Set.of(), Set.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        assertThat(zipNameCaptor.getValue()).endsWith(".zip");
        assertThat(listZipEntries(uploadDataCaptor.getValue())).isEmpty();
    }

    @Test
    void save_createsZipWithOneJp() throws Exception {
        underTest.save(Set.of(createJp()), Set.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        assertThat(zipNameCaptor.getValue()).endsWith(".zip");
        assertThat(listZipEntries(uploadDataCaptor.getValue())).containsExactly("jp/JP_9353_234_2025-10-17_2.xml");
    }

    @Test
    void save_ignoreDuplicateEntries() throws Exception {
        underTest.save(Set.of(createJp(), createJp()), Set.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        assertThat(zipNameCaptor.getValue()).endsWith(".zip");
        assertThat(listZipEntries(uploadDataCaptor.getValue())).containsExactly("jp/JP_9353_234_2025-10-17_2.xml");
    }
}
