package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.indications.internal.model.RuIndicationEntry;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplate;
import ch.sbb.das.backend.indications.internal.model.RuIndicationTemplateRequest;
import java.util.function.Consumer;
import org.springframework.stereotype.Component;

@Component
public class RuIndicationTemplateMapper {

    private static RuIndicationEntry toTemplateEntry(String title, String text) {
        if (title == null && text == null) {
            return null;
        }
        return new RuIndicationEntry(title, text);
    }

    public RuIndicationTemplate toResponse(RuIndicationTemplateEntity entity) {
        return new RuIndicationTemplate(
            entity.getId(),
            entity.getCategory(),
            toTemplateEntry(entity.getTitleDe(), entity.getTextDe()),
            toTemplateEntry(entity.getTitleFr(), entity.getTextFr()),
            toTemplateEntry(entity.getTitleIt(), entity.getTextIt()),
            entity.getCompanies(),
            entity.getLastModifiedAt(),
            entity.getLastModifiedBy()
        );
    }

    public RuIndicationTemplateEntity toEntityFromRequest(Integer id, RuIndicationTemplateRequest request) {
        RuIndicationTemplateEntity entity = new RuIndicationTemplateEntity();
        entity.setId(id);
        return updateEntityFromRequest(entity, request);
    }

    public RuIndicationTemplateEntity updateEntityFromRequest(RuIndicationTemplateEntity entity, RuIndicationTemplateRequest request) {
        entity.setCategory(request.category());
        setLanguageFields(request.de(), entity::setTitleDe, entity::setTextDe);
        setLanguageFields(request.fr(), entity::setTitleFr, entity::setTextFr);
        setLanguageFields(request.it(), entity::setTitleIt, entity::setTextIt);
        entity.setCompanies(request.companies());
        return entity;
    }

    private void setLanguageFields(RuIndicationEntry entry, Consumer<String> setTitle, Consumer<String> setText) {
        setTitle.accept(entry != null ? entry.title() : null);
        setText.accept(entry != null ? entry.text() : null);
    }
}
