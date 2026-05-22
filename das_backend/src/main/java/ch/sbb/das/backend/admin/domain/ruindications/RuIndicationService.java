package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationRequest;
import java.util.List;

public interface RuIndicationService {

    List<RuIndication> getAll();

    RuIndication getById(Integer id);

    RuIndication create(RuIndicationRequest createRequest);

    RuIndication update(Integer id, RuIndicationRequest updateRequest);

    void delete(Integer id);

    void delete(List<Integer> ids);
}
