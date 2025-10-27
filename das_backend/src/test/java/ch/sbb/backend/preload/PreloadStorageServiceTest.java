package ch.sbb.backend.preload;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.OTNIDComplexType;
import ch.sbb.backend.preload.sfera.model.v0300.TrainIdentificationComplexType;
import ch.sbb.backend.preload.xml.SferaMessagingConfig;
import ch.sbb.backend.preload.xml.XmlDateHelper;
import ch.sbb.backend.preload.xml.XmlHelper;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest(classes = {PreloadStorageService.class, XmlHelper.class, SferaMessagingConfig.class})
@ActiveProfiles("test")
class PreloadStorageServiceTest {

    @MockitoBean
    S3Service s3Service;

    @Autowired
    PreloadStorageService underTest;

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

        TrainIdentificationComplexType trainId = new TrainIdentificationComplexType();
        OTNIDComplexType otnid = new OTNIDComplexType();
        otnid.setTeltsiCompany("9353");
        otnid.setTeltsiOperationalTrainNumber("234");
        otnid.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(LocalDate.of(2025, 10, 17)));
        trainId.setOTNID(otnid);
        journeyProfile.setTrainIdentification(trainId);
        journeyProfile.setJPVersion(2L);
        return journeyProfile;
    }

    @Test
    void test_doesNotCreateEmptyDirectoriesWhenNoFiles() throws Exception {
        underTest.save(List.of(), List.of(), List.of());

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
    void test_createsZipWithOneJp() throws Exception {
        underTest.save(List.of(createJp()), List.of(), List.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        String zipName = zipNameCaptor.getValue();
        byte[] zipBytes = uploadDataCaptor.getValue();

        List<String> entries = listZipEntries(zipBytes);

        assertThat(zipName).endsWith(".zip");
        assertThat(entries).containsExactly("jp/JP_9353_234_2025-10-17_2.xml");
    }
}
