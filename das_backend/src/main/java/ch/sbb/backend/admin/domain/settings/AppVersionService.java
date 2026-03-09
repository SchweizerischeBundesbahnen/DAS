package ch.sbb.backend.admin.domain.settings;

import ch.sbb.backend.admin.application.settings.model.request.AppVersionRequest;
import ch.sbb.backend.admin.application.settings.model.response.AppVersion;
import ch.sbb.backend.admin.application.settings.model.response.CurrentAppVersion;
import java.util.List;

public interface AppVersionService {

    List<AppVersion> getAll();

    CurrentAppVersion getCurrent(String version);

    boolean isExpired(AppVersion appVersion);

    AppVersion getById(Integer id);

    AppVersion update(Integer id, AppVersionRequest updateRequest);

    AppVersion create(AppVersionRequest createRequest);

    void delete(Integer id);
}
