package ch.sbb.backend.admin.domain.service;

import ch.sbb.backend.admin.domain.model.ServicePoint;
import java.util.List;
import java.util.Optional;

public interface ServicePointService {

    List<ServicePoint> getAll();

    Optional<ServicePoint> findByUic(int uic);

    void updateAll(List<ServicePoint> servicePoints);

    void create(ServicePoint servicePoint);
}
