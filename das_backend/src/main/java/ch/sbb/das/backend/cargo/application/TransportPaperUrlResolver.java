package ch.sbb.das.backend.cargo.application;

import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.API_TRANSPORT_PAPERS;
import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.PARAM_COUNTRY_CODE_ISO;
import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.PARAM_LOCATION_PRIMARY_CODE;
import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.PARAM_PASS_INDEX;

import ch.sbb.das.backend.cargo.api.v1.model.TransportPaperLink;
import ch.sbb.das.backend.cargo.api.v1.model.TransportPaperLink.TransportPaperLinkType;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class TransportPaperUrlResolver {

    private static final String COMPANY_SBBCH = "2185";
    private static final String COMPANY_SBBI = "5184";
    private static final String COMPANY_BLSC = "3356";
    private static final int DEFAULT_PASS_INDEX = 0;
    private static final String SBBCH_URL_TEMPLATE = API_TRANSPORT_PAPERS + "/%s/%s?"
        + PARAM_COUNTRY_CODE_ISO + "=%s&"
        + PARAM_LOCATION_PRIMARY_CODE + "=%s&"
        + PARAM_PASS_INDEX + "=%d";
    private static final String SBBI_URL_TEMPLATE = "%s/#/zugliste/%s/%s/%d/%d/%d/RID_BEFOERDERUNGSDOKUMENT";

    private final String sbbiBaseUrl;
    private final String blscAppLink;

    public TransportPaperUrlResolver(@Value("${formation.transport-paper.sbbi-base-url}") String sbbiBaseUrl, @Value("${formation.transport-paper.blsc-app-link}") String blscAppLink) {
        this.sbbiBaseUrl = sbbiBaseUrl;
        this.blscAppLink = blscAppLink;
    }

    public TransportPaperLink resolve(TrainFormationRunEntity entity) {
        if (entity.getCompany() == null || !StringUtils.hasText(entity.getCompany().value())) {
            return null;
        }

        return switch (entity.getCompany().value()) {
            case COMPANY_SBBCH -> buildSbbchLink(entity);
            case COMPANY_SBBI -> buildSbbiLink(entity);
            case COMPANY_BLSC -> new TransportPaperLink(blscAppLink, TransportPaperLinkType.URL);
            default -> null;
        };
    }

    private TransportPaperLink buildSbbchLink(TrainFormationRunEntity entity) {
        if (entity.getTafTapLocationUicStartCode() == null || entity.getTrainPathId() == null || entity.getOperationalDay() == null) {
            return null;
        }

        TafTapLocationReference locationReference = TafTapLocationReference.of(entity.getTafTapLocationUicStartCode());
        int passIndex = entity.getTafTapLocationUicStartPassIndex() != null ? entity.getTafTapLocationUicStartPassIndex() : DEFAULT_PASS_INDEX;

        String url = SBBCH_URL_TEMPLATE.formatted(
            entity.getTrainPathId(),
            entity.getOperationalDay(),
            locationReference.countryCodeIso(),
            locationReference.primaryCode(),
            passIndex
        );

        return new TransportPaperLink(url, TransportPaperLinkType.PDF_REDIRECT);
    }

    private TransportPaperLink buildSbbiLink(TrainFormationRunEntity entity) {
        if (entity.getTafTapLocationUicStartCode() == null || entity.getTrainPathId() == null || entity.getOperationalDay() == null) {
            return null;
        }
        TafTapLocationReference locationReference = TafTapLocationReference.of(entity.getTafTapLocationUicStartCode());
        int passIndex = entity.getTafTapLocationUicStartPassIndex() != null ? entity.getTafTapLocationUicStartPassIndex() : DEFAULT_PASS_INDEX;

        String url = SBBI_URL_TEMPLATE.formatted(
            sbbiBaseUrl,
            entity.getTrainPathId(),
            entity.getOperationalDay(),
            locationReference.countryCodeUic(),
            locationReference.primaryCodeWithCheckDigit(),
            passIndex
        );

        return new TransportPaperLink(url, TransportPaperLinkType.URL);
    }
}
