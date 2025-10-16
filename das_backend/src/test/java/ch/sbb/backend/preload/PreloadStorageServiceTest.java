package ch.sbb.backend.preload;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.preload.xml.XmlHelper;
import java.io.ByteArrayInputStream;
import java.io.IOException;
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

@SpringBootTest
@ActiveProfiles("test")
@Import(TestContainerConfiguration.class)
class PreloadStorageServiceTest {

    @Autowired
    XmlHelper xmlHelper;

    S3Service s3Service;
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

    @BeforeEach
    void setUp() {
        s3Service = mock(S3Service.class);
        underTest = new PreloadStorageService(xmlHelper, s3Service);
    }

    @Test
    void test_createsZipWithDirectories() throws Exception {
        underTest.save(List.of(), List.of(), List.of());

        ArgumentCaptor<String> zipNameCaptor = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<byte[]> uploadDataCaptor = ArgumentCaptor.forClass(byte[].class);
        verify(s3Service).uploadZip(zipNameCaptor.capture(), uploadDataCaptor.capture());

        List<String> entries = listZipEntries(uploadDataCaptor.getValue());
        assertThat(zipNameCaptor.getValue()).endsWith(".zip");
        assertThat(entries).contains("jp/", "sp/", "tc/");
        assertThat(entries.stream().anyMatch(n -> n.endsWith(".xml"))).isFalse();
    }
}
