package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplate;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplateRequest;
import ch.sbb.das.backend.admin.infrastructure.jpa.RuIndicationTemplateEntity;
import java.util.List;
import java.util.Optional;

public class RuIndicationTemplateServiceImpl implements RuIndicationTemplateService {

    private final RuIndicationTemplateRepository ruIndicationTemplateRepository;

    public RuIndicationTemplateServiceImpl(RuIndicationTemplateRepository ruIndicationTemplateRepository) {
        this.ruIndicationTemplateRepository = ruIndicationTemplateRepository;
    }

    @Override
    public List<RuIndicationTemplate> getAll() {
        return ruIndicationTemplateRepository.findAll();
    }

    @Override
    public RuIndicationTemplate getById(Integer id) {
        Optional<RuIndicationTemplate> optionalRuIndicationTemplate = ruIndicationTemplateRepository.findById(id);
        return optionalRuIndicationTemplate.orElse(null);
    }

    @Override
    public RuIndicationTemplate create(RuIndicationTemplateRequest createRequest) {
        RuIndicationTemplateEntity entity = RuIndicationTemplateEntity.from(createRequest);
        return ruIndicationTemplateRepository.save(entity.toRuIndicationTemplate());
    }

    @Override
    public RuIndicationTemplate update(Integer id, RuIndicationTemplateRequest updateRequest) {
        Optional<RuIndicationTemplate> optional = ruIndicationTemplateRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        RuIndicationTemplate old = optional.get();
        RuIndicationTemplate updated = new RuIndicationTemplate(
            old.id(),
            updateRequest.category(),
            updateRequest.de(),
            updateRequest.fr(),
            updateRequest.it()
        );
        return ruIndicationTemplateRepository.save(updated);
    }

    @Override
    public void delete(Integer id) {
        ruIndicationTemplateRepository.deleteById(id);
    }

    @Override
    public void delete(List<Integer> ids) {
        ruIndicationTemplateRepository.deleteAllById(ids.stream().distinct().toList());
    }
}
