package ch.sbb.das.backend.locations.internal;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
class TafTapLocationServiceImpl {

    private final TafTapLocationRepository tafTapLocationRepository;
    private final TafTapLocationMapper tafTapLocationMapper;

    public List<TafTapLocation> findAll() {
        return tafTapLocationRepository.findAll().stream().map(tafTapLocationMapper::toResponse).toList();
    }
}
