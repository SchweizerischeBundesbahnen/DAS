package ch.sbb.backend.admin.domain.settings;

import ch.sbb.backend.admin.application.settings.model.request.AppVersionUpdateRequest;
import ch.sbb.backend.admin.application.settings.model.response.CurrentAppVersion;
import ch.sbb.backend.admin.domain.settings.model.AppVersion;
import java.util.List;

public interface AppVersionService {

    List<AppVersion> getAll();

    CurrentAppVersion getCurrent(String version);

    AppVersion getOne(Integer id);

    AppVersion update(Integer id, AppVersionUpdateRequest updateRequest);
}
