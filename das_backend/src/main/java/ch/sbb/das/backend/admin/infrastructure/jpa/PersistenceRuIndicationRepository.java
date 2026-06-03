package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
class PersistenceRuIndicationRepository implements RuIndicationRepository {

    private final SpringDataJpaRuIndicationRepository ruIndicationRepository;

    PersistenceRuIndicationRepository(SpringDataJpaRuIndicationRepository ruIndicationRepository) {
        this.ruIndicationRepository = ruIndicationRepository;
    }

    @Override
    public List<RuIndication> findAll() {
        return ruIndicationRepository.findAll().stream().map(RuIndicationEntity::toRuIndication).toList();
    }

    @Override
    public Optional<RuIndication> findById(Integer id) {
        return ruIndicationRepository.findById(id).map(RuIndicationEntity::toRuIndication);
    }

    @Override
    public List<RuIndication> findAllById(Iterable<Integer> ids) {
        return ruIndicationRepository.findAllById(ids).stream().map(RuIndicationEntity::toRuIndication).toList();
    }

    @Override
    public RuIndication save(RuIndication ruIndication) {
        return ruIndicationRepository.save(RuIndicationEntity.from(ruIndication)).toRuIndication();
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        ruIndicationRepository.deleteAllById(ids);
    }

    @Override
    public void deleteAllBefore(LocalDate localDate) {
        ruIndicationRepository.deleteAllByLastPeriodBefore(localDate);
    }
}

