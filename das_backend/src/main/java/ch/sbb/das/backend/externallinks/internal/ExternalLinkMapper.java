package ch.sbb.das.backend.externallinks.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@Component
public class ExternalLinkMapper {

    public ExternalLink toResponse(ExternalLinkEntity entity) {
        return new ExternalLink(
            entity.getId(),
            entity.getCompanies(),
            new ExternalLinkContent(entity.getTitleDe(), entity.getLinkDe()),
            new ExternalLinkContent(entity.getTitleFr(), entity.getLinkFr()),
            new ExternalLinkContent(entity.getTitleIt(), entity.getLinkIt()),
            entity.getLastModifiedAt(),
            entity.getLastModifiedBy()
        );
    }

    public ExternalLinkEntity toEntityFromRequest(Integer id, ExternalLinkRequest request) {
        ExternalLinkEntity entity = new ExternalLinkEntity();
        entity.setId(id);
        applyRequestToEntity(entity, request);
        return entity;
    }

    public void updateEntityFromRequest(ExternalLinkEntity entity, ExternalLinkRequest request) {
        applyRequestToEntity(entity, request);
    }

    private LinkedHashSet<CompanyCode> normalizeCompanies(Set<CompanyCode> companies) {
        return companies.stream()
            .sorted(Comparator.comparing(CompanyCode::value))
            .collect(Collectors.toCollection(LinkedHashSet::new));
    }

    private void applyRequestToEntity(ExternalLinkEntity entity, ExternalLinkRequest request) {
        entity.setCompanies(normalizeCompanies(request.companies()));

        entity.setTitleDe(request.de() != null ? request.de().title() : null);
        entity.setLinkDe(request.de() != null ? request.de().link() : null);

        entity.setTitleFr(request.fr() != null ? request.fr().title() : null);
        entity.setLinkFr(request.fr() != null ? request.fr().link() : null);

        entity.setTitleIt(request.it() != null ? request.it().title() : null);
        entity.setLinkIt(request.it() != null ? request.it().link() : null);
    }
}
