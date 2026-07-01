package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.features.RuFeature;
import ch.sbb.das.backend.features.RuFeatureService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RuFeatureServiceImpl implements RuFeatureService {

    private final RuFeatureRepository ruFeatureRepository;
    private final RuFeatureMapper ruFeatureMapper;

    @Override
    public List<RuFeature> getAll() {
        return ruFeatureRepository.findAll().stream()
            .map(ruFeatureMapper::toResponse)
            .toList();
    }

}
