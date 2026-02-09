package ch.sbb.backend.admin.domain.settings;

import java.util.List;

public interface AppVersionRepository {

    List<AppVersion> findAll();

}
