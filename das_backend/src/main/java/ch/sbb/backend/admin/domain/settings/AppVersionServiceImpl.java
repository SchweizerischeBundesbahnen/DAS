package ch.sbb.backend.admin.domain.settings;

import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AppVersionServiceImpl implements AppVersionService {

    @Override
    public List<AppVersion> getAll() {
        return List.of();
    }
}
