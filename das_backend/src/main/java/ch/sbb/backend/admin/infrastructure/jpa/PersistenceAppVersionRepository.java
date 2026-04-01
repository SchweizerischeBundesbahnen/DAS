package ch.sbb.backend.admin.infrastructure.jpa;

import ch.sbb.backend.admin.application.settings.model.response.AppVersion;
import ch.sbb.backend.admin.domain.settings.AppVersionRepository;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
class PersistenceAppVersionRepository implements AppVersionRepository {

    private final SpringDataJpaAppVersionRepository appVersionRepository;

    PersistenceAppVersionRepository(SpringDataJpaAppVersionRepository appVersionRepository) {
        this.appVersionRepository = appVersionRepository;
    }

    @Override
    public List<AppVersion> findAll() {
        return appVersionRepository.findAll().stream().map(AppVersionEntity::toAppVersion).toList();
    }

    @Override
    public Optional<AppVersion> findById(Integer id) {
        return appVersionRepository.findById(id).map(AppVersionEntity::toAppVersion);
    }

    @Override
    public AppVersion save(AppVersion appVersion) {
        AppVersionEntity entity = new AppVersionEntity();
        entity.setId(appVersion.id());
        entity.setVersion(appVersion.version());
        entity.setMinimalVersion(appVersion.minimalVersion());
        entity.setExpiryDate(appVersion.expiryDate());
        AppVersionEntity saved = appVersionRepository.save(entity);
        return saved.toAppVersion();
    }

    @Override
    public void deleteById(Integer id) {
        appVersionRepository.deleteById(id);
    }

    @Override
    public boolean existsByVersion(String version, Integer selfId) {
        return appVersionRepository.existsByVersionAndIdNot(version, selfId);
    }
}
