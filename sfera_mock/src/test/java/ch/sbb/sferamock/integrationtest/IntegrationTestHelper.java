package ch.sbb.sferamock.integrationtest;

import static ch.sbb.sferamock.integrationtest.IntegrationTestData.IM_COMPANY_CODE_SBB_INFRA;
import static ch.sbb.sferamock.integrationtest.IntegrationTestData.OPERATIONAL_NUMBER_T9999;
import static ch.sbb.sferamock.integrationtest.IntegrationTestData.RU_COMPANY_CODE_SBB_AG;
import static ch.sbb.sferamock.integrationtest.IntegrationTestData.SFERA_INCOMING_TOPIC;
import static ch.sbb.sferamock.integrationtest.IntegrationTestData.START_DATE;
import static ch.sbb.sferamock.integrationtest.SferaIntegrationTestData.READONLY_CONNECTED_BOARDCALCULATION;

import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAG2BReplyMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfileReference;
import java.util.UUID;
import lombok.experimental.UtilityClass;
import lombok.val;

@UtilityClass
public final class IntegrationTestHelper {

    public static void registerClient(TestMessageAdapter testMessageAdapter) {
        // Given
        val requestMessage = SferaIntegrationTestData.createHandshakeRequest(UUID.randomUUID(), RU_COMPANY_CODE_SBB_AG,
            IM_COMPANY_CODE_SBB_INFRA, READONLY_CONNECTED_BOARDCALCULATION);

        // When
        testMessageAdapter.sendXml(requestMessage, SFERA_INCOMING_TOPIC);

        // Then
        testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
    }

    public static SegmentProfileReference firstSpRef(TestMessageAdapter testMessageAdapter) {
        // Given
        val requestMessage = SferaIntegrationTestData.createSferaJpRequest(UUID.randomUUID(), RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA, OPERATIONAL_NUMBER_T9999, START_DATE);

        // When
        testMessageAdapter.sendXml(requestMessage, SFERA_INCOMING_TOPIC);

        // Then
        JourneyProfile journeyProfile = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class).getG2BReplyPayload().getJourneyProfile().getFirst();
        return journeyProfile.getSegmentProfileReference().getFirst();
    }

    public static void async(Runnable runnable) {
        new Thread(runnable).start();
    }
}
