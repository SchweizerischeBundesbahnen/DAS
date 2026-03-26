package ch.sbb.backend.admin.domain.locations;

import java.util.List;

public interface LocationRepository {

    List<Location> findAll();

    void saveAll(List<Location> locations);

    void deleteAll();

}
