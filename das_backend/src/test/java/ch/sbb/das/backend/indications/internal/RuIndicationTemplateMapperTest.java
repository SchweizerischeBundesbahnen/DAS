package ch.sbb.das.backend.indications.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.RuIndicationEntry;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplate;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplateRequest;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuIndicationTemplateMapperTest {

    private final RuIndicationTemplateMapper mapper = new RuIndicationTemplateMapper();

    private static CompanyCode company(String value) {
        return new CompanyCode(value);
    }

    @Test
    void toResponse_returns_null_language_when_title_and_text_are_missing() {
        RuIndicationTemplateEntity entity = new RuIndicationTemplateEntity();
        entity.setId(7);
        entity.setCategory("INFO");
        entity.setTitleDe("Titel DE");
        entity.setTextDe("Text DE");
        entity.setCompanies(Set.of(company("1111")));

        RuIndicationTemplate response = mapper.toResponse(entity);

        assertThat(response.id()).isEqualTo(7);
        assertThat(response.category()).isEqualTo("INFO");
        assertThat(response.de()).isEqualTo(new RuIndicationEntry("Titel DE", "Text DE"));
        assertThat(response.fr()).isNull();
        assertThat(response.it()).isNull();
        assertThat(response.companies()).containsExactly(company("1111"));
    }

    @Test
    void toEntityFromRequest_sets_id_and_maps_languages() {
        RuIndicationTemplateRequest request = new RuIndicationTemplateRequest(
            "SAFETY",
            new RuIndicationEntry("DE", "Text DE"),
            null,
            new RuIndicationEntry("IT", "Text IT"),
            Set.of(company("1111"), company("2222"))
        );

        RuIndicationTemplateEntity entity = mapper.toEntityFromRequest(99, request);

        assertThat(entity.getId()).isEqualTo(99);
        assertThat(entity.getCategory()).isEqualTo("SAFETY");
        assertThat(entity.getTitleDe()).isEqualTo("DE");
        assertThat(entity.getTextDe()).isEqualTo("Text DE");
        assertThat(entity.getTitleFr()).isNull();
        assertThat(entity.getTextFr()).isNull();
        assertThat(entity.getTitleIt()).isEqualTo("IT");
        assertThat(entity.getTextIt()).isEqualTo("Text IT");
        assertThat(entity.getCompanies()).containsExactlyInAnyOrder(company("1111"), company("2222"));
    }

    @Test
    void updateEntityFromRequest_clears_languages_missing_in_request() {
        RuIndicationTemplateEntity entity = new RuIndicationTemplateEntity();
        entity.setTitleDe("old de");
        entity.setTextDe("old de text");
        entity.setTitleFr("old fr");
        entity.setTextFr("old fr text");

        RuIndicationTemplateRequest request = new RuIndicationTemplateRequest(
            "UPDATED",
            null,
            new RuIndicationEntry("FR", "Text FR"),
            null,
            Set.of(company("1111"))
        );

        mapper.updateEntityFromRequest(entity, request);

        assertThat(entity.getCategory()).isEqualTo("UPDATED");
        assertThat(entity.getTitleDe()).isNull();
        assertThat(entity.getTextDe()).isNull();
        assertThat(entity.getTitleFr()).isEqualTo("FR");
        assertThat(entity.getTextFr()).isEqualTo("Text FR");
        assertThat(entity.getTitleIt()).isNull();
        assertThat(entity.getTextIt()).isNull();
    }
}

