package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

class InMemoryRuIndicationRepository implements RuIndicationRepository {

    private final AtomicInteger idSequence = new AtomicInteger(1);
    private final Map<Integer, RuIndication> ruIndications = new LinkedHashMap<>();

    @Override
    public List<RuIndication> findAll() {
        return new ArrayList<>(ruIndications.values());
    }

    @Override
    public Optional<RuIndication> findById(Integer id) {
        return Optional.ofNullable(ruIndications.get(id));
    }

    @Override
    public List<RuIndication> findAllById(Iterable<Integer> ids) {
        List<RuIndication> result = new ArrayList<>();
        for (Integer id : ids) {
            RuIndication ruIndication = ruIndications.get(id);
            if (ruIndication != null) {
                result.add(ruIndication);
            }
        }
        return result;
    }

    @Override
    public RuIndication save(RuIndication ruIndication) {
        Integer id = ruIndication.id() == null ? idSequence.getAndIncrement() : ruIndication.id();
        RuIndication persisted = new RuIndication(id, ruIndication.content(), ruIndication.scope(), ruIndication.periods(), ruIndication.lastModifiedAt(), ruIndication.lastModifiedBy());
        ruIndications.put(id, persisted);
        return persisted;
    }

    @Override
    public void deleteById(Integer id) {
        ruIndications.remove(id);
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        for (Integer id : ids) {
            ruIndications.remove(id);
        }
    }
}

