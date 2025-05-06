package ch.sbb.backend.admin.domain.servicepoint;

import ch.sbb.backend.admin.domain.servicepoint.model.ServicePoint;
import java.util.List;
import java.util.Optional;

public interface ServicePointService {

    List<ServicePoint> getAll();

    Optional<ServicePoint> findByUic(int uic);

    void updateAll(List<ServicePoint> servicePoints);

    void create(ServicePoint servicePoint);
}
