package ch.sbb.sferamock;

import static ch.sbb.sferamock.IntegrationTestData.IM_COMPANY_CODE_SBB_INFRA;
import static ch.sbb.sferamock.IntegrationTestData.RU_COMPANY_CODE_SBB_AG;
import static ch.sbb.sferamock.IntegrationTestData.SFERA_INCOMING_TOPIC;
import static ch.sbb.sferamock.IntegrationTestHelper.async;
import static ch.sbb.sferamock.IntegrationTestHelper.firstSpRef;
import static ch.sbb.sferamock.IntegrationTestHelper.registerClient;
import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAG2BReplyMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfileReference;
import ch.sbb.sferamock.messages.common.SferaErrorCodes;
import java.util.UUID;
import lombok.val;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@IntegrationTest
class SegmentProfileRequestTest {

    public static final UUID REQUEST_MESSAGE_ID = UUID.randomUUID();

    @Autowired
    private TestMessageAdapter testMessageAdapter;

    @Test
    void handleSegmentProfileRequest_notRegistered_errorPublished() {
        // Given
        val sferaSegmentProfileRequest = SferaIntegrationTestData.createSferaSpRequest(REQUEST_MESSAGE_ID, RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA, "0", "0", "SPID");
        // When
        testMessageAdapter.sendXml(sferaSegmentProfileRequest, SFERA_INCOMING_TOPIC);

        // Then
        val sferaReply = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        SferaAssertions.assertReplyError(sferaReply, SferaErrorCodes.COULD_NOT_PROCESS_DATA);
        assertThat(sferaReply.getMessageHeader().getCorrelationID()).isEqualTo(REQUEST_MESSAGE_ID.toString());
    }

    @Test
    void handleSegmentProfileRequest_SegmentProfileReceived_SegmentProfilePublished() {
        // Given
        registerClient(testMessageAdapter);
        SegmentProfileReference spRef = firstSpRef(testMessageAdapter);
        val sferaSegmentProfileRequest = SferaIntegrationTestData.createSferaSpRequest(REQUEST_MESSAGE_ID, RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA, spRef.getSPVersionMajor(),
            spRef.getSPVersionMinor(), spRef.getSPID());

        // When
        // a client sends us the sfera segment profile request
        async(() -> testMessageAdapter.sendXml(sferaSegmentProfileRequest, SFERA_INCOMING_TOPIC));

        // Then
        val sferaReply = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        val payload = sferaReply.getG2BReplyPayload();
        assertThat(payload.getSegmentProfile()).hasSize(1);
        val sp = payload.getSegmentProfile().getFirst();
        assertThat(sp.getSPStatus()).isEqualTo("Valid");
        assertThat(sferaReply.getMessageHeader().getCorrelationID()).isEqualTo(REQUEST_MESSAGE_ID.toString());
    }
}
