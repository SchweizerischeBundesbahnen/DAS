package ch.sbb.sferamock;

import static ch.sbb.sferamock.IntegrationTestData.IM_COMPANY_CODE_SBB_I;
import static ch.sbb.sferamock.IntegrationTestData.OPERATIONAL_NUMBER_T9999;
import static ch.sbb.sferamock.IntegrationTestData.RU_COMPANY_CODE_SBB_P;
import static ch.sbb.sferamock.IntegrationTestData.SFERA_INCOMING_TOPIC;
import static ch.sbb.sferamock.IntegrationTestData.START_DATE;
import static ch.sbb.sferamock.IntegrationTestHelper.async;
import static ch.sbb.sferamock.IntegrationTestHelper.registerClient;
import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.sferamock.adapters.sfera.model.v0300.SFERAG2BReplyMessage;
import java.util.UUID;
import lombok.val;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@IntegrationTest
class JourneyProfileRequestTest {

    public static final UUID REQUEST_MESSAGE_ID = UUID.randomUUID();

    @Autowired
    private TestMessageAdapter messageAdapter;

    @Test
    void handleJourneyProfileRequest_journeyProfileReceived_journeyProfilePublished() {
        // Given
        registerClient(messageAdapter);
        val sferaJourneyProfileRequest = SferaIntegrationTestData
            .createSferaJpRequest(REQUEST_MESSAGE_ID,
                RU_COMPANY_CODE_SBB_P, IM_COMPANY_CODE_SBB_I,
                OPERATIONAL_NUMBER_T9999, START_DATE);
        // When
        // a client sends us the sfera journey profile request
        async(() -> messageAdapter.sendXml(sferaJourneyProfileRequest, SFERA_INCOMING_TOPIC));

        // Then
        val sferaReply = messageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        assertThat(sferaReply).as("SFERA published JourneyProfile to the client").isNotNull();
        assertThat(sferaReply.getMessageHeader().getCorrelationID()).isEqualTo(REQUEST_MESSAGE_ID.toString());
        val messageHeader = sferaReply.getMessageHeader();
        assertThat(messageHeader.getMessageID()).isNotNull();
        assertThat(sferaReply.getHandshakeReject()).isNull();
        assertThat(sferaReply.getHandshakeAcknowledgement()).isNull();
        val payload = sferaReply.getG2BReplyPayload();
        assertThat(payload.getJourneyProfile()).hasSize(1);
        assertThat(payload.getJourneyProfile().getFirst().getSegmentProfileReference().getFirst().getSPZone().getIMID())
            .isEqualTo(IM_COMPANY_CODE_SBB_I.value());
        assertThat(payload.getJourneyProfile().getFirst().getTrainIdentification().getOTNID().getTeltsiCompany()).isEqualTo(RU_COMPANY_CODE_SBB_P.value());
        assertThat(payload.getJourneyProfile().getFirst().getTrainIdentification().getOTNID().getTeltsiOperationalTrainNumber()).isEqualTo(OPERATIONAL_NUMBER_T9999);
    }
}
