package ch.sbb.backend.preload.application;

import static org.xmlunit.assertj3.XmlAssert.assertThat;

import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.TrainIdentification;
import ch.sbb.backend.preload.infrastructure.xml.SferaMessagingConfig;
import ch.sbb.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GRequestMessage;
import java.time.LocalDate;
import java.util.Set;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.xmlunit.builder.Input;
import org.xmlunit.util.Nodes;

@SpringBootTest(classes = {SferaMessageCreator.class, XmlHelper.class, SferaMessagingConfig.class})
@ActiveProfiles("test")
class SferaMessageCreatorTest {

    @Autowired
    SferaMessageCreator sferaMessageCreator;

    @Autowired
    XmlHelper xmlHelper;

    @Test
    void test_createJpRequestMessage() {
        SFERAB2GRequestMessage message = sferaMessageCreator.createJpRequestMessage(new TrainIdentification("1111", "51", LocalDate.of(2025, 10, 6)));
        String result = xmlHelper.toString(message);

        assertThat(result).and(Input.fromFile("src/test/resources/sfera/jprequest.xml"))
            .ignoreWhitespace()
            .ignoreChildNodesOrder()
            .withAttributeFilter(attr -> {
                String localName = Nodes.getQName(attr).getLocalPart();
                return !localName.equals("timestamp") && !localName.equals("message_ID");
            })
            .areIdentical();
    }

    @Test
    void test_createSpRequestMessage() {
        SFERAB2GRequestMessage message = sferaMessageCreator.createSpRequestMessage(
            Set.of(new SegmentProfileIdentification("234", "3", "2", "1200", null), new SegmentProfileIdentification("41", "1", "0", "1300", (short) 810)));
        String result = xmlHelper.toString(message);

        assertThat(result).and(Input.fromFile("src/test/resources/sfera/sprequest.xml"))
            .ignoreWhitespace()
            .ignoreChildNodesOrder()
            .withAttributeFilter(attr -> {
                String localName = Nodes.getQName(attr).getLocalPart();
                return !localName.equals("timestamp") && !localName.equals("message_ID");
            })
            .areSimilar();
    }
}