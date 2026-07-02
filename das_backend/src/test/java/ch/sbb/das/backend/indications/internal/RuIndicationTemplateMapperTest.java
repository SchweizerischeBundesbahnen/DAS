package ch.sbb.das.backend.indications.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplate;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplateEntry;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplateRequest;
import org.junit.jupiter.api.Test;

class RuIndicationTemplateMapperTest {

    private final RuIndicationTemplateMapper mapper = new RuIndicationTemplateMapper();

    @Test
    void toResponse_returns_null_language_when_title_and_text_are_missing() {
        RuIndicationTemplateEntity entity = new RuIndicationTemplateEntity();
        entity.setId(7);
        entity.setCategory("INFO");
        entity.setTitleDe("Titel DE");
        entity.setTextDe("Text DE");
        entity.setTenant("tenant1");

        RuIndicationTemplate response = mapper.toResponse(entity);

        assertThat(response.id()).isEqualTo(7);
        assertThat(response.category()).isEqualTo("INFO");
        assertThat(response.de()).isEqualTo(new RuIndicationTemplateEntry("Titel DE", "Text DE"));
        assertThat(response.fr()).isNull();
        assertThat(response.it()).isNull();
        assertThat(response.tenant()).isEqualTo("tenant1");
    }

    @Test
    void toEntityFromRequest_sets_id_and_maps_languages() {
        RuIndicationTemplateRequest request = new RuIndicationTemplateRequest(
            "SAFETY",
            new RuIndicationTemplateEntry("DE", "Text DE"),
            null,
            new RuIndicationTemplateEntry("IT", "Text IT")
        );

        RuIndicationTemplateEntity entity = mapper.toEntityFromRequest(99, request, "tenant2");

        assertThat(entity.getId()).isEqualTo(99);
        assertThat(entity.getCategory()).isEqualTo("SAFETY");
        assertThat(entity.getTitleDe()).isEqualTo("DE");
        assertThat(entity.getTextDe()).isEqualTo("Text DE");
        assertThat(entity.getTitleFr()).isNull();
        assertThat(entity.getTextFr()).isNull();
        assertThat(entity.getTitleIt()).isEqualTo("IT");
        assertThat(entity.getTextIt()).isEqualTo("Text IT");
        assertThat(entity.getTenant()).isEqualTo("tenant2");
    }

    @Test
    void updateEntityFromRequest_clears_languages_missing_in_request() {
        RuIndicationTemplateEntity entity = new RuIndicationTemplateEntity();
        entity.setTitleDe("old de");
        entity.setTextDe("old de text");
        entity.setTitleFr("old fr");
        entity.setTextFr("old fr text");
        entity.setTenant("never");

        RuIndicationTemplateRequest request = new RuIndicationTemplateRequest(
            "UPDATED",
            null,
            new RuIndicationTemplateEntry("FR", "Text FR"),
            null
        );

        mapper.updateEntityFromRequest(entity, request, "tenant1");

        assertThat(entity.getCategory()).isEqualTo("UPDATED");
        assertThat(entity.getTitleDe()).isNull();
        assertThat(entity.getTextDe()).isNull();
        assertThat(entity.getTitleFr()).isEqualTo("FR");
        assertThat(entity.getTextFr()).isEqualTo("Text FR");
        assertThat(entity.getTitleIt()).isNull();
        assertThat(entity.getTextIt()).isNull();
        assertThat(entity.getTenant()).isEqualTo("tenant1");
    }
}

