package ch.sbb.das.backend.indications.internal;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RuIndicationTemplateRepository extends ListCrudRepository<RuIndicationTemplateEntity, Integer> {

}
