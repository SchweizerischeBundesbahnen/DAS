package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.admin.domain.settings.AppVersion;
import ch.sbb.backend.admin.domain.settings.AppVersionService;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AppVersionServiceImpl implements AppVersionService {

    @Override
    public List<AppVersion> getAll() {
        return List.of();
    }
}
