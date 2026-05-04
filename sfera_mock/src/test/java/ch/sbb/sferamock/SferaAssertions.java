package ch.sbb.sferamock;

import static org.assertj.core.api.AssertionsForInterfaceTypes.assertThat;

import ch.sbb.sferamock.adapters.sfera.model.v0400.B2GMessageResponse;
import ch.sbb.sferamock.adapters.sfera.model.v0400.HandshakeRejectReason;
import ch.sbb.sferamock.adapters.sfera.model.v0400.SFERAG2BReplyMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0400.UnavailableDASOperatingModes;
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
        assertThat(replyMessage.getDASHandshakeReject()).isNull();
        assertThat(replyMessage.getDASHandshakeAcknowledgement()).isNull();
        assertThat(replyMessage.getG2BReplyPayload().getG2BMessageResponse().getResult()).isEqualTo(B2GMessageResponse.Result.ERROR);
        assertThat(replyMessage.getG2BReplyPayload().getG2BMessageResponse().getG2BError()).hasSize(1);
        assertThat(replyMessage.getG2BReplyPayload().getG2BMessageResponse().getG2BError().getFirst().getErrorCode()).isEqualTo(errorCode.getCode());
    }

    void assertHandshakeAcknowledgement(SFERAG2BReplyMessage replyMessage, UnavailableDASOperatingModes.DASConnectivity connectivity) {
        assertThat(replyMessage.getDASHandshakeReject()).isNull();
        assertThat(replyMessage.getDASHandshakeAcknowledgement()).isNotNull();
        assertThat(replyMessage.getDASHandshakeAcknowledgement().getDASOperatingModeSelected().getDASConnectivity()).isEqualTo(connectivity);
    }

    void assertHandshakeReject(SFERAG2BReplyMessage replyMessage, List<HandshakeRejectReason> rejectReason) {
        assertThat(replyMessage.getDASHandshakeAcknowledgement()).isNull();
        assertThat(replyMessage.getDASHandshakeReject()).isNotNull();
        assertThat(replyMessage.getDASHandshakeReject().getHandshakeRejectReason()).isEqualTo(rejectReason);
    }
}
