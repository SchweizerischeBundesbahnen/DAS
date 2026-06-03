package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplate;
import java.util.List;
import java.util.Optional;

public interface RuIndicationTemplateRepository {

    List<RuIndicationTemplate> findAll();

    Optional<RuIndicationTemplate> findById(Integer id);

    RuIndicationTemplate save(RuIndicationTemplate appVersion);
    
    void deleteAllById(Iterable<Integer> ids);

}
