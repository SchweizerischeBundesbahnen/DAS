package ch.sbb.backend.admin.domain.servicepoint;

import ch.sbb.backend.admin.domain.servicepoint.model.ServicePoint;
import java.util.List;
import java.util.Optional;

public class ServicePointServiceImpl implements ServicePointService {

    private final ServicePointRepository servicePointRepository;

    public ServicePointServiceImpl(ServicePointRepository servicePointRepository) {
        this.servicePointRepository = servicePointRepository;
    }

    @Override
    public List<ServicePoint> getAll() {
        return servicePointRepository.findAll();
    }

    @Override
    public Optional<ServicePoint> findByUic(int uic) {
        return servicePointRepository.findByUic(uic);
    }

    @Override
    public void updateAll(List<ServicePoint> servicePoints) {
        servicePointRepository.saveAll(servicePoints);
    }

    @Override
    public void create(ServicePoint servicePoint) {
        servicePointRepository.save(servicePoint);
    }
}
