package ch.sbb.das.backend.indications.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.OperationalTrainNumberFilter;
import ch.sbb.das.backend.indications.internal.model.RuIndication;
import ch.sbb.das.backend.indications.internal.model.RuIndicationContent;
import ch.sbb.das.backend.indications.internal.model.RuIndicationEntry;
import ch.sbb.das.backend.indications.internal.model.RuIndicationPeriod;
import ch.sbb.das.backend.indications.internal.model.RuIndicationRequest;
import ch.sbb.das.backend.indications.internal.model.RuIndicationScope;
import ch.sbb.das.backend.indications.internal.model.TrainNumberParity;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuIndicationMapperTest {

    private final RuIndicationMapper mapper = new RuIndicationMapper();

    private static CompanyCode company(String value) {
        return new CompanyCode(value);
    }

    @Test
    void toResponse_defaults_null_collections_and_empty_languages() {
        RuIndicationEntity entity = new RuIndicationEntity();
        entity.setId(1);
        entity.setCategory("INFO");
        entity.setTitleDe("Titel DE");
        entity.setTextDe("Text DE");
        entity.setCompanies(Set.of(company("1111")));

        RuIndication response = mapper.toResponse(entity);

        assertThat(response.id()).isEqualTo(1);
        assertThat(response.content().category()).isEqualTo("INFO");
        assertThat(response.content().de()).isEqualTo(new RuIndicationEntry("Titel DE", "Text DE"));
        assertThat(response.content().fr()).isNull();
        assertThat(response.content().it()).isNull();
        assertThat(response.scope().companies()).containsExactly(company("1111"));
        assertThat(response.scope().operationalTrainNumberFilters()).isEmpty();
        assertThat(response.scope().tafTapLocationReferences()).isEmpty();
        assertThat(response.periods()).isEmpty();
    }

    @Test
    void toResponse_deduplicates_location_references() {
        RuIndicationEntity entity = new RuIndicationEntity();
        entity.setCompanies(Set.of(company("1111")));
        entity.setTafTapLocationReferences(List.of(
            TafTapLocationReference.of("CH07000"),
            TafTapLocationReference.of("CH07000"),
            TafTapLocationReference.of("CH08000")
        ));

        RuIndication response = mapper.toResponse(entity);

        assertThat(response.scope().tafTapLocationReferences())
            .containsExactlyInAnyOrder(TafTapLocationReference.of("CH07000"), TafTapLocationReference.of("CH08000"));
    }

    @Test
    void toEntityFromRequest_sets_id_and_maps_scope_defaults() {
        RuIndicationRequest request = new RuIndicationRequest(
            new RuIndicationContent("SAFETY", new RuIndicationEntry("DE", "Text DE"), null, null),
            new RuIndicationScope(
                Set.of(company("1111"), company("2222")),
                null,
                Set.of(TafTapLocationReference.of("CH07000"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 10), Set.of(DayOfWeek.MONDAY)))
        );

        RuIndicationEntity entity = mapper.toEntityFromRequest(77, request);

        assertThat(entity.getId()).isEqualTo(77);
        assertThat(entity.getCategory()).isEqualTo("SAFETY");
        assertThat(entity.getTitleDe()).isEqualTo("DE");
        assertThat(entity.getTextDe()).isEqualTo("Text DE");
        assertThat(entity.getOperationalTrainNumberFilters()).isEmpty();
        assertThat(entity.getTafTapLocationReferences()).containsExactly(TafTapLocationReference.of("CH07000"));
        assertThat(entity.getPeriods()).hasSize(1);
    }

    @Test
    void updateEntityFromRequest_keeps_existing_optional_language_when_not_present_in_request() {
        RuIndicationEntity entity = new RuIndicationEntity();
        entity.setTitleFr("Old FR");
        entity.setTextFr("Old FR Text");

        RuIndicationRequest request = new RuIndicationRequest(
            new RuIndicationContent(
                "UPDATED",
                new RuIndicationEntry("DE", "Text DE"),
                null,
                null
            ),
            new RuIndicationScope(
                Set.of(company("1111")),
                List.of(new OperationalTrainNumberFilter("100-200", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH07000"))
            ),
            List.of()
        );

        mapper.updateEntityFromRequest(entity, request);

        assertThat(entity.getCategory()).isEqualTo("UPDATED");
        assertThat(entity.getTitleDe()).isEqualTo("DE");
        assertThat(entity.getTextDe()).isEqualTo("Text DE");
        assertThat(entity.getTitleFr()).isEqualTo("Old FR");
        assertThat(entity.getTextFr()).isEqualTo("Old FR Text");
        assertThat(entity.getOperationalTrainNumberFilters())
            .containsExactly(new OperationalTrainNumberFilter("100-200", TrainNumberParity.ANY));
    }
}

