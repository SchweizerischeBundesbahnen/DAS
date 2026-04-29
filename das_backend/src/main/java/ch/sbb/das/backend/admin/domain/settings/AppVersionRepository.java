package ch.sbb.das.backend.admin.domain.settings;

import ch.sbb.das.backend.admin.application.settings.model.response.AppVersion;
import java.util.List;
import java.util.Optional;

public interface AppVersionRepository {

    List<AppVersion> findAll();

    Optional<AppVersion> findById(Integer id);

    AppVersion save(AppVersion appVersion);

    void deleteById(Integer id);

    boolean existsByVersion(String version, Integer selfId);
}
