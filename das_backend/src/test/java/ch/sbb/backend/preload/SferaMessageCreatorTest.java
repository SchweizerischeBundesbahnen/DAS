package ch.sbb.backend.preload;

import static org.xmlunit.assertj3.XmlAssert.assertThat;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.preload.sfera.model.v0300.JPRequest;
import ch.sbb.backend.preload.sfera.model.v0300.MessageHeader;
import ch.sbb.backend.preload.xml.XmlHelper;
import java.time.LocalDate;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.xmlunit.builder.Input;
import org.xmlunit.util.Nodes;

@SpringBootTest
@ActiveProfiles("test")
@Import(TestContainerConfiguration.class)
class SferaMessageCreatorTest {

    @Autowired
    SferaMessageCreator sferaMessageCreator;

    @Autowired
    XmlHelper xmlHelper;

    @Test
    void test_createJPRequest() {
        JPRequest jpRequest = sferaMessageCreator.createJPRequest("1111", "51", LocalDate.of(2025, 10, 6));
        String result = xmlHelper.toString(jpRequest);

        assertThat(result).and(Input.fromFile("src/test/resources/sfera/jprequest.xml")).ignoreWhitespace().areIdentical();
    }

    @Test
    void test_createMessageHeader() {
        MessageHeader header = sferaMessageCreator.createMessageHeader(UUID.fromString("4a597056-0a2a-4381-98ca-46430b4b3a14"));
        String result = xmlHelper.toString(header);

        assertThat(result).and(Input.fromFile("src/test/resources/sfera/messageheader.xml")).ignoreWhitespace().withAttributeFilter(attr ->
            !(Nodes.getQName(attr).getLocalPart().equals("timestamp"))).areIdentical();
    }
}