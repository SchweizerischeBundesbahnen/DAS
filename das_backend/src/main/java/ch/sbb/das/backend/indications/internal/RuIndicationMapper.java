package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.indications.internal.model.RuIndication;
import ch.sbb.das.backend.indications.internal.model.RuIndicationContent;
import ch.sbb.das.backend.indications.internal.model.RuIndicationEntry;
import ch.sbb.das.backend.indications.internal.model.RuIndicationRequest;
import ch.sbb.das.backend.indications.internal.model.RuIndicationScope;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Component;

@Component
public class RuIndicationMapper {

    private static RuIndicationEntry toTemplateContent(String title, String text) {
        if (title == null && text == null) {
            return null;
        }
        return new RuIndicationEntry(title, text);
    }

    public RuIndication toResponse(RuIndicationEntity entity) {
        RuIndicationContent content = new RuIndicationContent(
            entity.getCategory(),
            toTemplateContent(entity.getTitleDe(), entity.getTextDe()),
            toTemplateContent(entity.getTitleFr(), entity.getTextFr()),
            toTemplateContent(entity.getTitleIt(), entity.getTextIt())
        );

        RuIndicationScope scope = new RuIndicationScope(
            entity.getCompanies(),
            entity.getOperationalTrainNumberFilters() == null ? List.of() : entity.getOperationalTrainNumberFilters(),
            entity.getTafTapLocationReferences() == null ? Set.of() : new HashSet<>(entity.getTafTapLocationReferences())
        );

        return new RuIndication(
            entity.getId(),
            content,
            scope,
            entity.getPeriods() == null ? List.of() : entity.getPeriods(),
            entity.getLastModifiedAt(),
            entity.getLastModifiedBy()
        );
    }

    public RuIndicationEntity toEntityFromRequest(Integer id, RuIndicationRequest ruIndication) {
        RuIndicationEntity entity = new RuIndicationEntity();
        entity.setId(id);
        return updateEntityFromRequest(entity, ruIndication);
    }

    public RuIndicationEntity updateEntityFromRequest(RuIndicationEntity entity, RuIndicationRequest request) {
        entity.setCategory(request.content().category());
        if (request.content().de() != null) {
            entity.setTitleDe(request.content().de().title());
            entity.setTextDe(request.content().de().text());
        }
        if (request.content().fr() != null) {
            entity.setTitleFr(request.content().fr().title());
            entity.setTextFr(request.content().fr().text());
        }
        if (request.content().it() != null) {
            entity.setTitleIt(request.content().it().title());
            entity.setTextIt(request.content().it().text());
        }
        entity.setCompanies(request.scope().companies());
        entity.setOperationalTrainNumberFilters(
            request.scope().operationalOperationalTrainNumberFilters() == null ? List.of() : request.scope().operationalOperationalTrainNumberFilters());
        entity.setTafTapLocationReferences(request.scope().tafTapLocationReferences() == null ? List.of() : request.scope().tafTapLocationReferences().stream().distinct().toList());
        entity.setPeriods(request.periods());
        return entity;
    }
}
