package ch.sbb.das.backend.cargo.application;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.cargo.api.v1.model.TransportPaperLink;
import ch.sbb.das.backend.cargo.api.v1.model.TransportPaperLink.TransportPaperLinkType;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.companies.CompanyCode;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class TransportPaperUrlResolverTest {

    private final TransportPaperUrlResolver resolver = new TransportPaperUrlResolver(
        "https://sbbi.example.com",
        "https://blsc.example.com"
    );

    @Test
    void resolve_forSbbCh_returnsRelativeProxyLink() {
        TrainFormationRunEntity entity = TrainFormationRunEntity.builder()
            .company(new CompanyCode("2185"))
            .trainPathId("33014-021")
            .operationalDay(LocalDate.of(2026, 1, 30))
            .tafTapLocationUicStartCode(85221370)
            .tafTapLocationUicStartPassIndex(3)
            .build();

        TransportPaperLink result = resolver.resolve(entity);

        assertThat(result).isNotNull();
        assertThat(result.url())
            .isEqualTo("/driver/v1/transport-papers/33014-021/2026-01-30?countryCodeIso=CH&locationPrimaryCode=22137&bpZusatzId=3");
        assertThat(result.type()).isEqualTo(TransportPaperLinkType.PDF_REDIRECT);
    }

    @Test
    void resolve_forSbbI_returnsDirectLink() {
        TrainFormationRunEntity entity = TrainFormationRunEntity.builder()
            .company(new CompanyCode("5184"))
            .trainPathId("61078-001")
            .operationalDay(LocalDate.of(2026, 7, 30))
            .tafTapLocationUicStartCode(85014035)
            .tafTapLocationUicStartPassIndex(0)
            .build();

        TransportPaperLink result = resolver.resolve(entity);

        assertThat(result).isNotNull();
        assertThat(result.url())
            .isEqualTo("https://sbbi.example.com/#/zugliste/61078-001/2026-07-30/85/14035/0/RID_BEFOERDERUNGSDOKUMENT");
        assertThat(result.type()).isEqualTo(TransportPaperLinkType.URL);
    }

    @Test
    void resolve_forSbbI_withMissingUicCode_returnsNull() {
        TrainFormationRunEntity entity = TrainFormationRunEntity.builder()
            .company(new CompanyCode("5184"))
            .trainPathId("61078-001")
            .operationalDay(LocalDate.of(2026, 7, 30))
            .build();

        assertThat(resolver.resolve(entity)).isNull();
    }

    @Test
    void resolve_forBlsc_returnsDirectAppLink() {
        TrainFormationRunEntity entity = TrainFormationRunEntity.builder()
            .company(new CompanyCode("3356"))
            .build();

        TransportPaperLink result = resolver.resolve(entity);

        assertThat(result).isNotNull();
        assertThat(result.url()).isEqualTo("https://blsc.example.com");
        assertThat(result.type()).isEqualTo(TransportPaperLinkType.URL);
    }

    @Test
    void resolve_forUnsupportedCompany_returnsNull() {
        TrainFormationRunEntity entity = TrainFormationRunEntity.builder()
            .company(new CompanyCode("1111"))
            .build();

        TransportPaperLink result = resolver.resolve(entity);

        assertThat(result).isNull();
    }
}
