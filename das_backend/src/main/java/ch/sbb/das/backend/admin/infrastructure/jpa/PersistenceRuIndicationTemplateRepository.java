package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplate;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationTemplateRepository;
import ch.sbb.das.backend.companies.CompanyCode;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

@Component
class PersistenceRuIndicationTemplateRepository implements RuIndicationTemplateRepository {

    private final SpringDataJpaRuIndicationTemplateRepository ruIndicationTemplateRepository;

    PersistenceRuIndicationTemplateRepository(SpringDataJpaRuIndicationTemplateRepository ruIndicationTemplateRepository) {
        this.ruIndicationTemplateRepository = ruIndicationTemplateRepository;
    }

    @Override
    public List<RuIndicationTemplate> findAll() {
        return ruIndicationTemplateRepository.findAll().stream().map(RuIndicationTemplateEntity::toRuIndicationTemplate).toList();
    }

    @Override
    public Optional<RuIndicationTemplate> findById(Integer id) {
        return ruIndicationTemplateRepository.findById(id).map(RuIndicationTemplateEntity::toRuIndicationTemplate);
    }

    @Override
    public RuIndicationTemplate save(RuIndicationTemplate ruIndicationTemplate) {
        RuIndicationTemplateEntity entity = new RuIndicationTemplateEntity();
        entity.setId(ruIndicationTemplate.id());
        entity.setCategory(ruIndicationTemplate.category());
        if (ruIndicationTemplate.de() != null) {
            entity.setTitleDe(ruIndicationTemplate.de().title());
            entity.setTextDe(ruIndicationTemplate.de().text());
        }
        if (ruIndicationTemplate.fr() != null) {
            entity.setTitleFr(ruIndicationTemplate.fr().title());
            entity.setTextFr(ruIndicationTemplate.fr().text());
        }
        if (ruIndicationTemplate.it() != null) {
            entity.setTitleIt(ruIndicationTemplate.it().title());
            entity.setTextIt(ruIndicationTemplate.it().text());
        }
        entity.setCompanies(ruIndicationTemplate.companies().stream()
            .sorted(Comparator.comparing(CompanyCode::value))
            .collect(Collectors.toCollection(LinkedHashSet::new)));
        RuIndicationTemplateEntity saved = ruIndicationTemplateRepository.save(entity);
        return saved.toRuIndicationTemplate();
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        ruIndicationTemplateRepository.deleteAllById(ids);
    }

    @Override
    public List<RuIndicationTemplate> findAllById(Iterable<Integer> ids) {
        return ruIndicationTemplateRepository.findAllById(ids).stream().map(RuIndicationTemplateEntity::toRuIndicationTemplate).toList();
    }
}
