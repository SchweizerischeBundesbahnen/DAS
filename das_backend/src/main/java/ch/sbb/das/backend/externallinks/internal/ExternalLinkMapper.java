package ch.sbb.das.backend.externallinks.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.function.Consumer;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@Component
public class ExternalLinkMapper {

    private static void setLanguageFields(ExternalLinkContent content, Consumer<String> setTitle, Consumer<String> setLink) {
        setTitle.accept(content != null ? content.title() : null);
        setLink.accept(content != null ? content.link() : null);
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

    private static ExternalLinkContent toLinkContent(String title, String link) {
        if (title == null && link == null) {
            return null;
        }
        return new ExternalLinkContent(title, link);
    }

    public ExternalLink toResponse(ExternalLinkEntity entity) {
        return new ExternalLink(
            entity.getId(),
            entity.getCompanies(),
            toLinkContent(entity.getTitleDe(), entity.getLinkDe()),
            toLinkContent(entity.getTitleFr(), entity.getLinkFr()),
            toLinkContent(entity.getTitleIt(), entity.getLinkIt()),
            entity.getLastModifiedAt(),
            entity.getLastModifiedBy()
        );
    }

    private void applyRequestToEntity(ExternalLinkEntity entity, ExternalLinkRequest request) {
        entity.setCompanies(normalizeCompanies(request.companies()));

        setLanguageFields(request.de(), entity::setTitleDe, entity::setLinkDe);
        setLanguageFields(request.fr(), entity::setTitleFr, entity::setLinkFr);
        setLanguageFields(request.it(), entity::setTitleIt, entity::setLinkIt);
    }
}
