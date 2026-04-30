package ch.sbb.das.backend.admin.domain.locations;

import java.util.List;

public interface TafTapLocationRepository {

    List<TafTapLocation> findAll();

    void saveAll(List<TafTapLocation> locations);

    void deleteAll();

}
