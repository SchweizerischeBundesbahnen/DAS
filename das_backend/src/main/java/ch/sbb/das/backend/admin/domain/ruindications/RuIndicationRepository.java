package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import java.util.List;
import java.util.Optional;

public interface RuIndicationRepository {

    List<RuIndication> findAll();

    Optional<RuIndication> findById(Integer id);

    List<RuIndication> findAllById(Iterable<Integer> ids);

    RuIndication save(RuIndication ruIndication);
    
    void deleteAllById(Iterable<Integer> ids);
}

