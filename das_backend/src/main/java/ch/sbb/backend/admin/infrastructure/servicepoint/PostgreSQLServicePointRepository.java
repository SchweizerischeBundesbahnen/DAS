package ch.sbb.backend.admin.infrastructure.servicepoint;

import ch.sbb.backend.admin.domain.servicepoint.ServicePointRepository;
import ch.sbb.backend.admin.domain.servicepoint.model.ServicePoint;
import ch.sbb.backend.admin.infrastructure.servicepoint.model.ServicePointEntity;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
class PostgreSQLServicePointRepository implements ServicePointRepository {

    private final SpringDataJpaServicePointRepository servicePointRepository;

    PostgreSQLServicePointRepository(SpringDataJpaServicePointRepository servicePointRepository) {
        this.servicePointRepository = servicePointRepository;
    }

    @Override
    public Optional<ServicePoint> findByUic(int uic) {
        return servicePointRepository.findByUic(uic).map(ServicePointEntity::toServicePoint);
    }

    @Override
    public List<ServicePoint> findAll() {
        return servicePointRepository.findAll().stream().map(ServicePointEntity::toServicePoint).toList();
    }

    @Override
    public void saveAll(List<ServicePoint> servicePoints) {
        servicePointRepository.saveAll(servicePoints.stream().map(ServicePointEntity::new).toList());
    }

    @Override
    public void save(ServicePoint servicePoint) {
        servicePointRepository.save(new ServicePointEntity(servicePoint));
    }
}
