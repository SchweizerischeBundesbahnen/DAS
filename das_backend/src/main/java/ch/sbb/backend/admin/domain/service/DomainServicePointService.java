package ch.sbb.backend.admin.domain.service;

import ch.sbb.backend.admin.domain.ServicePoint;
import ch.sbb.backend.admin.domain.repository.ServicePointRepository;
import java.util.List;
import java.util.Optional;

public class DomainServicePointService implements ServicePointService {

    private final ServicePointRepository servicePointRepository;

    public DomainServicePointService(ServicePointRepository servicePointRepository) {
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
