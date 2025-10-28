package ch.sbb.sferamock.integrationtest;

import static org.assertj.core.api.AssertionsForInterfaceTypes.assertThat;

import ch.sbb.sferamock.adapters.sfera.model.v0201.B2GMessageResponse;
import ch.sbb.sferamock.adapters.sfera.model.v0201.HandshakeRejectReason;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SFERAG2BReplyMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0201.UnavailableDASOperatingModes;
import ch.sbb.sferamock.messages.common.SferaErrorCodes;
import java.util.List;
import java.util.UUID;
import lombok.experimental.UtilityClass;

@UtilityClass
public class SferaAssertions {

    void assertMessageIdAndCorrelationId(SFERAG2BReplyMessage replyMessage, UUID messageId) {
        assertThat(replyMessage.getMessageHeader().getMessageID()).isNotEqualTo(messageId.toString());
        assertThat(replyMessage.getMessageHeader().getCorrelationID()).isEqualTo(messageId.toString());
    }

    void assertReplyError(SFERAG2BReplyMessage replyMessage, SferaErrorCodes errorCode) {
        assertThat(replyMessage.getHandshakeReject()).isNull();
        assertThat(replyMessage.getHandshakeAcknowledgement()).isNull();
        assertThat(replyMessage.getG2BReplyPayload().getG2BMessageResponse().getResult()).isEqualTo(B2GMessageResponse.Result.ERROR);
        assertThat(replyMessage.getG2BReplyPayload().getG2BMessageResponse().getG2BError()).hasSize(1);
        assertThat(replyMessage.getG2BReplyPayload().getG2BMessageResponse().getG2BError().getFirst().getErrorCode()).isEqualTo(errorCode.getCode());
    }

    void assertHandshakeAcknowledgement(SFERAG2BReplyMessage replyMessage, UnavailableDASOperatingModes.DASConnectivity connectivity) {
        assertThat(replyMessage.getHandshakeReject()).isNull();
        assertThat(replyMessage.getHandshakeAcknowledgement()).isNotNull();
        assertThat(replyMessage.getHandshakeAcknowledgement().getDASOperatingModeSelected().getDASConnectivity()).isEqualTo(connectivity);
    }

    void assertHandshakeReject(SFERAG2BReplyMessage replyMessage, List<HandshakeRejectReason> rejectReason) {
        assertThat(replyMessage.getHandshakeAcknowledgement()).isNull();
        assertThat(replyMessage.getHandshakeReject()).isNotNull();
        assertThat(replyMessage.getHandshakeReject().getHandshakeRejectReason()).isEqualTo(rejectReason);
    }
}
