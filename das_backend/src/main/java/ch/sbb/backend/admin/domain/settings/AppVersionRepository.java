package ch.sbb.backend.admin.domain.settings;

import ch.sbb.backend.admin.domain.settings.model.AppVersion;
import java.util.List;
import java.util.Optional;

public interface AppVersionRepository {

    List<AppVersion> findAll();

    Optional<AppVersion> findById(Integer id);

    AppVersion save(AppVersion appVersion);

    void deleteById(Integer id);
}
