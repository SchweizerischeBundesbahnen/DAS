package ch.sbb.backend.preload;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.preload.sfera.model.v0201.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0201.OTNIDComplexType;
import ch.sbb.backend.preload.sfera.model.v0201.TrainIdentificationComplexType;
import ch.sbb.backend.preload.xml.XmlDateHelper;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@SpringBootTest
@ActiveProfiles("test")
@Import(TestContainerConfiguration.class)
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

    @BeforeEach
    void resetAndStubS3Service() {
        reset(s3Service);
        doNothing().when(s3Service).uploadZip(any(String.class), any(byte[].class));
    }

    @Test
    void test_doesNotCreateEmptyDirectoriesWhenNoFiles() throws Exception {
        underTest.save(List.of(), List.of(), List.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service, times(1)).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        String zipName = zipNameCaptor.getValue();
        byte[] zipBytes = uploadDataCaptor.getValue();

        assertThat(zipName).endsWith(".zip");

        List<String> entries = listZipEntries(zipBytes);

        assertThat(entries).isEmpty();
        //        assertThat(entries).containsExactly("jp/", "sp/", "tc/");

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
