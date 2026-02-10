package ch.sbb.backend.admin.application.settings;

import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AppVersionServiceImpl implements AppVersionService {

    private final AppVersionRepository repository;

    public AppVersionServiceImpl(AppVersionRepository repository) {
        this.repository = repository;
    }

    @Override
    public List<AppVersionEntity> getAll() {
        return repository.findAll();
    }
}
