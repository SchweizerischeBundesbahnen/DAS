package ch.sbb.sferamock;

import static ch.sbb.sferamock.IntegrationTestData.IM_COMPANY_CODE_SBB_INFRA;
import static ch.sbb.sferamock.IntegrationTestData.RU_COMPANY_CODE_SBB_AG;
import static ch.sbb.sferamock.IntegrationTestData.SFERA_INCOMING_TOPIC;
import static ch.sbb.sferamock.SferaIntegrationTestData.DRIVER_CONNECTED_BOARDCALCULATION;
import static ch.sbb.sferamock.SferaIntegrationTestData.INACTIVE_STANDALONE_BOARDCALCULATION;
import static ch.sbb.sferamock.SferaIntegrationTestData.READONLY_CONNECTED_BOARDCALCULATION;
import static ch.sbb.sferamock.SferaIntegrationTestData.READONLY_CONNECTED_GROUNDCALCULATION;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.HandshakeRejectReason.ARCHITECTURE_NOT_SUPPORTED;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.UnavailableDASOperatingModes.DASConnectivity.CONNECTED;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.UnavailableDASOperatingModes.DASConnectivity.STANDALONE;

import ch.sbb.sferamock.adapters.sfera.model.v0300.SFERAB2GRequestMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0300.SFERAG2BReplyMessage;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@IntegrationTest
class HandshakeITest {

    static final UUID MESSAGE_ID = UUID.randomUUID();

    @Autowired
    private TestMessageAdapter testMessageAdapter;

    @Test
    void handleHandshakeRequest_drivingModeInactiveAndStandalone_handshakeAcknowledge() {
        // Given
        SFERAB2GRequestMessage handshakeRequest = SferaIntegrationTestData.createHandshakeRequest(
            MESSAGE_ID, RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA,
            INACTIVE_STANDALONE_BOARDCALCULATION);

        // When
        testMessageAdapter.sendXml(handshakeRequest, SFERA_INCOMING_TOPIC);

        // Then
        SFERAG2BReplyMessage replyMessage = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        SferaAssertions.assertMessageIdAndCorrelationId(replyMessage, MESSAGE_ID);
        SferaAssertions.assertHandshakeAcknowledgement(replyMessage, STANDALONE);
    }

    @Test
    void handleHandshakeRequest_wrongArchitecture_handshakeReject() {
        // Given
        SFERAB2GRequestMessage handshakeRequest = SferaIntegrationTestData.createHandshakeRequest(
            MESSAGE_ID, RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA,
            READONLY_CONNECTED_GROUNDCALCULATION);

        // When
        testMessageAdapter.sendXml(handshakeRequest, SFERA_INCOMING_TOPIC);

        // Then
        SFERAG2BReplyMessage replyMessage = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        SferaAssertions.assertMessageIdAndCorrelationId(replyMessage, MESSAGE_ID);
        SferaAssertions.assertHandshakeReject(replyMessage, List.of(ARCHITECTURE_NOT_SUPPORTED));
    }

    @Test
    void handleHandshakeRequest_drivingModeDriverAndReadOnly_handshakeAcknowledge() {
        // Given
        SFERAB2GRequestMessage handshakeRequest = SferaIntegrationTestData.createHandshakeRequest(
            MESSAGE_ID, RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA,
            DRIVER_CONNECTED_BOARDCALCULATION, READONLY_CONNECTED_BOARDCALCULATION);
        handshakeRequest.getHandshakeRequest().setStatusReportsEnabled(true);

        // When
        testMessageAdapter.sendXml(handshakeRequest, SFERA_INCOMING_TOPIC);

        // Then
        SFERAG2BReplyMessage replyMessage = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        SferaAssertions.assertMessageIdAndCorrelationId(replyMessage, MESSAGE_ID);
        SferaAssertions.assertHandshakeAcknowledgement(replyMessage, CONNECTED);
    }

    @Test
    void handleHandshakeRequest_drivingModeReadOnlyAndDriver_handshakeAcknowledge() {
        // Given
        SFERAB2GRequestMessage handshakeRequest = SferaIntegrationTestData.createHandshakeRequest(
            MESSAGE_ID, RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA,
            READONLY_CONNECTED_BOARDCALCULATION, DRIVER_CONNECTED_BOARDCALCULATION);
        handshakeRequest.getHandshakeRequest().setStatusReportsEnabled(true);

        // When
        testMessageAdapter.sendXml(handshakeRequest, SFERA_INCOMING_TOPIC);

        // Then
        SFERAG2BReplyMessage replyMessage = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        SferaAssertions.assertMessageIdAndCorrelationId(replyMessage, MESSAGE_ID);
        SferaAssertions.assertHandshakeAcknowledgement(replyMessage, CONNECTED);
    }

    @Test
    void handleHandshakeRequest_drivingModeReadOnly_handshakeAcknowledge() {
        // When
        testMessageAdapter.sendXml(SferaIntegrationTestData.createHandshakeRequest(MESSAGE_ID), SFERA_INCOMING_TOPIC);

        // Then
        SFERAG2BReplyMessage replyMessage = testMessageAdapter.receiveXml(SFERAG2BReplyMessage.class);
        SferaAssertions.assertMessageIdAndCorrelationId(replyMessage, MESSAGE_ID);
        SferaAssertions.assertHandshakeAcknowledgement(replyMessage, CONNECTED);
    }
}
