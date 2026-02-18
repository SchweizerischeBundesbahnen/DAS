package ch.sbb.backend.admin.domain.settings;

import ch.sbb.backend.admin.application.settings.model.request.AppVersionUpdateRequest;
import ch.sbb.backend.admin.application.settings.model.response.CurrentAppVersion;
import ch.sbb.backend.admin.domain.settings.model.AppVersion;
import ch.sbb.backend.admin.domain.settings.model.SemVersion;
import ch.sbb.backend.admin.infrastructure.settings.AppVersionRepository;
import ch.sbb.backend.admin.infrastructure.settings.model.AppVersionEntity;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import org.springframework.stereotype.Service;

@Service
public class AppVersionServiceImpl implements AppVersionService {

    private final AppVersionRepository repository;

    public AppVersionServiceImpl(AppVersionRepository repository) {
        this.repository = repository;
    }

    @Override
    public List<AppVersion> getAll() {
        return repository.findAll().stream()
            .map(entity ->
                new AppVersion(entity.getId(), entity.getVersion(), entity.getMinimalVersion(), entity.getExpiryDate()))
            .toList();
    }

    @Override
    public CurrentAppVersion getCurrent(String appVersion) {
        if (appVersion == null) {
            return CurrentAppVersion.DEFAULT;
        }
        SemVersion currentVersion = new SemVersion(appVersion);

        List<AppVersionEntity> relevantVersions = repository.findAll().stream()
            .filter(entity -> isBlockedVersion(entity, currentVersion) || isMinimalVersionGreater(entity, currentVersion))
            .toList();

        boolean expired = relevantVersions.stream()
            .anyMatch(this::isExpired);

        LocalDate expiryDate = relevantVersions.stream()
            .map(AppVersionEntity::getExpiryDate)
            .filter(Objects::nonNull)
            .filter(date -> date.isAfter(LocalDate.now()))
            .min(Comparator.naturalOrder())
            .orElse(null);

        return new CurrentAppVersion(expired, expiryDate);
    }

    private boolean isBlockedVersion(AppVersionEntity entity, SemVersion currentVersion) {
        return !entity.getMinimalVersion() && currentVersion.equals(new SemVersion(entity.getVersion()));
    }

    private boolean isMinimalVersionGreater(AppVersionEntity entity, SemVersion currentVersion) {
        return entity.getMinimalVersion() && currentVersion.isLowerThan(new SemVersion(entity.getVersion()));
    }

    private boolean isExpired(AppVersionEntity entity) {
        LocalDate expiryDate = entity.getExpiryDate();
        return expiryDate == null || expiryDate.isBefore(LocalDate.now());
    }

    @Override
    public AppVersion getOne(Integer id) {
        AppVersionEntity entity = repository.findById(id).orElse(null);
        if (entity == null) {
            return null;
        }
        return new AppVersion(entity.getId(), entity.getVersion(), entity.getMinimalVersion(), entity.getExpiryDate());
    }

    @Override
    public AppVersion create(AppVersionUpdateRequest createRequest) {
        AppVersionEntity entity = new AppVersionEntity();
        entity.setVersion(createRequest.version());
        entity.setMinimalVersion(createRequest.minimalVersion());
        entity.setExpiryDate(createRequest.expiryDate());
        entity.setLastModifiedAt(java.time.LocalDateTime.now());
        entity.setLastModifiedBy(createRequest.lastModifiedBy());
        repository.save(entity);
        return new AppVersion(entity.getId(), entity.getVersion(), entity.getMinimalVersion(), entity.getExpiryDate());
    }

    @Override
    public AppVersion update(Integer id, AppVersionUpdateRequest updateRequest) {
        AppVersionEntity entity = repository.findById(id).orElse(null);
        if (entity == null) {
            return null;
        }
        entity.setVersion(updateRequest.version());
        entity.setMinimalVersion(updateRequest.minimalVersion());
        entity.setExpiryDate(updateRequest.expiryDate());
        entity.setLastModifiedAt(java.time.LocalDateTime.now());
        entity.setLastModifiedBy(updateRequest.lastModifiedBy());
        repository.save(entity);
        return new AppVersion(entity.getId(), entity.getVersion(), entity.getMinimalVersion(), entity.getExpiryDate());
    }
}
