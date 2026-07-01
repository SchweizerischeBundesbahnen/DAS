package ch.sbb.das.backend.externallinks.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.companies.CompanyCode;
import java.util.LinkedHashSet;
import java.util.Set;
import org.junit.jupiter.api.Test;

class ExternalLinkMapperTest {

    private final ExternalLinkMapper mapper = new ExternalLinkMapper();

    private static CompanyCode company(String value) {
        return new CompanyCode(value);
    }

    @Test
    void toResponse_maps_language_objects_and_returns_null_for_empty_languages() {
        ExternalLinkEntity entity = new ExternalLinkEntity();
        entity.setId(10);
        entity.setCompanies(Set.of(company("1111"), company("2222")));
        entity.setTitleFr("Titre FR");
        entity.setLinkFr("https://sbb.ch/fr");

        ExternalLink response = mapper.toResponse(entity);

        assertThat(response.id()).isEqualTo(10);
        assertThat(response.companies()).containsExactlyInAnyOrder(company("1111"), company("2222"));
        assertThat(response.de()).isNull();
        assertThat(response.fr()).isEqualTo(new ExternalLinkContent("Titre FR", "https://sbb.ch/fr"));
        assertThat(response.it()).isNull();
    }

    @Test
    void toEntityFromRequest_maps_id_sorts_companies_and_copies_languages() {
        ExternalLinkRequest request = new ExternalLinkRequest(
            new LinkedHashSet<>(Set.of(company("2222"), company("1111"))),
            null,
            new ExternalLinkContent("FR", "https://sbb.ch/fr"),
            null
        );

        ExternalLinkEntity entity = mapper.toEntityFromRequest(42, request);

        assertThat(entity.getId()).isEqualTo(42);
        assertThat(entity.getCompanies()).containsExactly(company("1111"), company("2222"));
        assertThat(entity.getTitleDe()).isNull();
        assertThat(entity.getLinkDe()).isNull();
        assertThat(entity.getTitleFr()).isEqualTo("FR");
        assertThat(entity.getLinkFr()).isEqualTo("https://sbb.ch/fr");
        assertThat(entity.getTitleIt()).isNull();
        assertThat(entity.getLinkIt()).isNull();
    }

    @Test
    void updateEntityFromRequest_overwrites_old_language_values_when_missing_in_request() {
        ExternalLinkEntity entity = new ExternalLinkEntity();
        entity.setTitleDe("Old DE");
        entity.setLinkDe("https://old.de");
        entity.setTitleFr("Old FR");
        entity.setLinkFr("https://old.fr");
        entity.setTitleIt("Old IT");
        entity.setLinkIt("https://old.it");

        ExternalLinkRequest request = new ExternalLinkRequest(
            Set.of(company("1111")),
            new ExternalLinkContent("DE", "https://new.de"),
            null,
            null
        );

        mapper.updateEntityFromRequest(entity, request);

        assertThat(entity.getTitleDe()).isEqualTo("DE");
        assertThat(entity.getLinkDe()).isEqualTo("https://new.de");
        assertThat(entity.getTitleFr()).isNull();
        assertThat(entity.getLinkFr()).isNull();
        assertThat(entity.getTitleIt()).isNull();
        assertThat(entity.getLinkIt()).isNull();
    }
}

