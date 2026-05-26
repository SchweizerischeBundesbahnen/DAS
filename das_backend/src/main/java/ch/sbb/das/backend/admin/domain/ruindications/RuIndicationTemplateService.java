package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplate;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplateRequest;
import java.util.List;

public interface RuIndicationTemplateService {

    List<RuIndicationTemplate> getAll();

    RuIndicationTemplate getById(Integer id);

    RuIndicationTemplate update(Integer id, RuIndicationTemplateRequest updateRequest);

    RuIndicationTemplate create(RuIndicationTemplateRequest createRequest);
    
    void delete(List<Integer> ids);
}
