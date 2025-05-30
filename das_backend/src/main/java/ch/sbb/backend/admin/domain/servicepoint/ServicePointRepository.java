package ch.sbb.backend.admin.domain.servicepoint;

import ch.sbb.backend.admin.domain.servicepoint.model.ServicePoint;
import java.util.List;
import java.util.Optional;

public interface ServicePointRepository {

    Optional<ServicePoint> findByUic(int uic);

    List<ServicePoint> findAll();

    void saveAll(List<ServicePoint> servicePoints);

    void save(ServicePoint servicePoint);

}
