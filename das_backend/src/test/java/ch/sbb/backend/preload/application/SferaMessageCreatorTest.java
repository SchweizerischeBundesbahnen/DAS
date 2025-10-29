package ch.sbb.backend.preload.application;

import static org.xmlunit.assertj3.XmlAssert.assertThat;

import ch.sbb.backend.preload.domain.SegmentProfileIdentification;
import ch.sbb.backend.preload.domain.TrainId;
import ch.sbb.backend.preload.infrastructure.xml.SferaMessagingConfig;
import ch.sbb.backend.preload.infrastructure.xml.XmlHelper;
import ch.sbb.backend.preload.sfera.model.v0300.SFERAB2GRequestMessage;
import java.time.LocalDate;
import java.util.Set;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.w3c.dom.Attr;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.DefaultNodeMatcher;
import org.xmlunit.diff.ElementSelectors;
import org.xmlunit.util.Nodes;
import org.xmlunit.util.Predicate;

@SpringBootTest(classes = {SferaMessageCreator.class, XmlHelper.class, SferaMessagingConfig.class})
@ActiveProfiles("test")
class SferaMessageCreatorTest {

    public static final Predicate<Attr> MESSAGE_HEADER_ATTR_FILTER = attr -> {
        String localName = Nodes.getQName(attr).getLocalPart();
        return !localName.equals("timestamp") && !localName.equals("message_ID");
    };

    public static final DefaultNodeMatcher SP_ID_NODE_MATCHER = new DefaultNodeMatcher(ElementSelectors.byNameAndAttributes("SP_Request", "SP_ID"));

    @Autowired
    SferaMessageCreator sferaMessageCreator;

    @Autowired
    XmlHelper xmlHelper;

    @Test
    void createJpRequestMessage() {
        SFERAB2GRequestMessage message = sferaMessageCreator.createJpRequestMessage(new TrainId("1111", "51", LocalDate.of(2025, 10, 6)));
        String result = xmlHelper.toString(message);

        assertThat(result).and(Input.fromFile("src/test/resources/sfera/jprequest.xml"))
            .ignoreWhitespace()
            .withAttributeFilter(MESSAGE_HEADER_ATTR_FILTER)
            .areIdentical();
    }

    @Test
    void createSpRequestMessage() {
        SFERAB2GRequestMessage message = sferaMessageCreator.createSpRequestMessage(
            Set.of(new SegmentProfileIdentification("234", "3", "2", "1200", null), new SegmentProfileIdentification("41", "1", "0", "1300", (short) 810)));
        String result = xmlHelper.toString(message);

        assertThat(result).and(Input.fromFile("src/test/resources/sfera/sprequest.xml"))
            .ignoreWhitespace()
            .withNodeMatcher(SP_ID_NODE_MATCHER)
            .withAttributeFilter(MESSAGE_HEADER_ATTR_FILTER)
            .areSimilar();
    }
}