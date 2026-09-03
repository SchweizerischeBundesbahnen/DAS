package ch.sbb.das.backend.driversettings.internal;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@EnableConfigurationProperties(TourSystemProperties.class)
class TourSystemService {

    private final TourSystemProperties tourSystemProperties;

    List<TourSystem> getAll() {
        return tourSystemProperties.toTourSystems();
    }
}
