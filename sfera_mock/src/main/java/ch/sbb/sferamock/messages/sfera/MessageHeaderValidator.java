package ch.sbb.sferamock.messages.sfera;

import ch.sbb.sferamock.adapters.sfera.model.v0201.MessageHeader;
import ch.sbb.sferamock.messages.common.SferaErrorCodes;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class MessageHeaderValidator {

    private static final Logger log = LoggerFactory.getLogger(MessageHeaderValidator.class);

    @Value("${sfera.company-code}")
    String tmsCompanyCode;

    @Value("${sfera.sfera-version}")
    String sferaVersion;

    public Optional<SferaErrorCodes> validate(MessageHeader messageHeader, String companyCode) {

        if (!sferaVersion.contains(messageHeader.getSFERAVersion())) {
            log.info("Error validating MessageHeader: wrong SFERA version {}", messageHeader.getSFERAVersion());
            return Optional.of(SferaErrorCodes.SFERA_XSD_VERSION_NOT_SUPPORTED);
        }
        if (!tmsCompanyCode.equals(messageHeader.getRecipient().getValue())) {
            log.info("Error validating MessageHeader: wrong recipient {}", messageHeader.getRecipient().getValue());
            return Optional.of(SferaErrorCodes.INTENDED_RECIPIENT_NOT_ACTUAL_RECIPIENT);
        }

        if (!companyCode.equals(messageHeader.getSender().getValue())) {
            log.info("Error validating MessageHeader: wrong sender {}", messageHeader.getSender().getValue());
            return Optional.of(SferaErrorCodes.ACTION_NOT_AUTHORIZED_FOR_USER);
        }
        return Optional.empty();
    }

}
