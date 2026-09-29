package ch.sbb.sferamock;

import static ch.sbb.sferamock.IntegrationTestData.IM_COMPANY_CODE_SBB_I;
import static ch.sbb.sferamock.IntegrationTestData.OPERATIONAL_NUMBER_T9999;
import static ch.sbb.sferamock.IntegrationTestData.RU_COMPANY_CODE_SBB_P;
import static ch.sbb.sferamock.IntegrationTestData.SFERA_INCOMING_TOPIC;
import static ch.sbb.sferamock.IntegrationTestData.START_DATE;
import static ch.sbb.sferamock.IntegrationTestHelper.async;
import static ch.sbb.sferamock.IntegrationTestHelper.registerClient;
import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.sferamock.adapters.sfera.model.v0400.SFERAG2BReplyMessage;
import java.util.UUID;
import lombok.val;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@IntegrationTest
class RelatedTrainInformationRequestTest {

    private static final String OPERATIONAL_NUMBER_WITHOUT_RTI = "T9998";

    @Autowired
    private TestMessageAdapter messageAdapter;

    @Test
    void handleRelatedTrainInformationRequest_staticRelatedTrainInformationDefined_relatedTrainInformationPublished() {
        // Given
        registerClient(messageAdapter);
        val requestMessageId = UUID.randomUUID();
        val request = SferaIntegrationTestData.createSferaRtiRequest(requestMessageId,
            RU_COMPANY_CODE_SBB_P, IM_COMPANY_CODE_SBB_I, OPERATIONAL_NUMBER_T9999, START_DATE);

        // When
        async(() -> messageAdapter.sendXml(request, SFERA_INCOMING_TOPIC));

        // Then
        val sferaReply = messageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        assertThat(sferaReply).isNotNull();
        assertThat(sferaReply.getMessageHeader().getCorrelationID()).isEqualTo(requestMessageId.toString());
        assertThat(sferaReply.getDASHandshakeReject()).isNull();
        assertThat(sferaReply.getDASHandshakeAcknowledgement()).isNull();

        val payload = sferaReply.getG2BReplyPayload();
        assertThat(payload.getG2BMessageResponse()).isNull();
        assertThat(payload.getRelatedTrainInformation()).hasSize(1);

        val relatedTrainInformation = payload.getRelatedTrainInformation().getFirst();
        val ownTrain = relatedTrainInformation.getOwnTrain();
        assertThat(ownTrain.getTrainIdentification().getOTNID().getTeltsiOperationalTrainNumber()).isEqualTo(OPERATIONAL_NUMBER_T9999);
        assertThat(ownTrain.getTrainIdentification().getOTNID().getTeltsiCompany()).isEqualTo(RU_COMPANY_CODE_SBB_P.value());
        val trainLocationInformation = ownTrain.getTrainLocationInformation();
        assertThat(trainLocationInformation).isNotNull();
        assertThat(trainLocationInformation.getPositionSpeed().getSPID()).isEqualTo("T9999_1");
        assertThat(trainLocationInformation.getPositionSpeed().getLocation()).isEqualTo(200.0);
    }

    @Test
    void handleRelatedTrainInformationRequest_noStaticRelatedTrainInformation_emptyTrainLocationInformationReplyPublished() {
        // Given
        registerClient(messageAdapter);
        val requestMessageId = UUID.randomUUID();
        val request = SferaIntegrationTestData.createSferaRtiRequest(requestMessageId,
            RU_COMPANY_CODE_SBB_P, IM_COMPANY_CODE_SBB_I, OPERATIONAL_NUMBER_WITHOUT_RTI, START_DATE);

        // When
        async(() -> messageAdapter.sendXml(request, SFERA_INCOMING_TOPIC));

        // Then
        val sferaReply = messageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        assertThat(sferaReply).isNotNull();
        assertThat(sferaReply.getMessageHeader().getCorrelationID()).isEqualTo(requestMessageId.toString());
        assertThat(sferaReply.getDASHandshakeReject()).isNull();
        assertThat(sferaReply.getDASHandshakeAcknowledgement()).isNull();

        val payload = sferaReply.getG2BReplyPayload();
        assertThat(payload.getG2BMessageResponse()).isNull();
        assertThat(payload.getRelatedTrainInformation()).hasSize(1);

        val ownTrain = payload.getRelatedTrainInformation().getFirst().getOwnTrain();
        assertThat(ownTrain.getTrainIdentification().getOTNID().getTeltsiOperationalTrainNumber()).isEqualTo(OPERATIONAL_NUMBER_T9999);
        val trainLocationInformation = ownTrain.getTrainLocationInformation();
        assertThat(trainLocationInformation).isNotNull();
        assertThat(trainLocationInformation.getPositionSpeed()).isNull();
    }
}
