package ch.sbb.backend.admin.domain.settings;

import ch.sbb.backend.admin.application.settings.model.request.AppVersionRequest;
import ch.sbb.backend.admin.application.settings.model.response.AppVersion;
import ch.sbb.backend.admin.application.settings.model.response.CurrentAppVersion;
import ch.sbb.backend.admin.domain.settings.model.SemanticVersion;
import ch.sbb.backend.admin.infrastructure.jpa.AppVersionEntity;
import ch.sbb.backend.common.ConflictException;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

public class AppVersionServiceImpl implements AppVersionService {

    private final AppVersionRepository appVersionRepository;

    public AppVersionServiceImpl(AppVersionRepository appVersionRepository) {
        this.appVersionRepository = appVersionRepository;
    }

    @Override
    public List<AppVersion> getAll() {
        return appVersionRepository.findAll();
    }

    @Override
    public CurrentAppVersion getCurrent(String appVersion) {
        if (appVersion == null) {
            return CurrentAppVersion.DEFAULT;
        }
        SemanticVersion currentVersion = new SemanticVersion(appVersion);

        List<AppVersion> relevantVersions = appVersionRepository.findAll().stream()
            .filter(entity -> isBlockedVersion(entity, currentVersion) || isMinimalVersionGreater(entity, currentVersion))
            .toList();

        boolean expired = relevantVersions.stream()
            .anyMatch(this::isExpired);

        LocalDate expiryDate = relevantVersions.stream()
            .map(AppVersion::expiryDate)
            .filter(Objects::nonNull)
            .filter(date -> date.isAfter(LocalDate.now()))
            .min(Comparator.naturalOrder())
            .orElse(null);

        return new CurrentAppVersion(expired, expiryDate);
    }

    @Override
    public boolean isExpired(AppVersion appVersion) {
        LocalDate expiryDate = appVersion.expiryDate();
        return expiryDate == null || expiryDate.isBefore(LocalDate.now());
    }

    @Override
    public AppVersion getById(Integer id) {
        Optional<AppVersion> entity = appVersionRepository.findById(id);
        return entity.orElse(null);
    }

    @Override
    public AppVersion create(AppVersionRequest createRequest) {
        checkUniqueVersion(createRequest.version(), null);
        AppVersionEntity entity = AppVersionEntity.from(createRequest);
        return appVersionRepository.save(entity.toAppVersion());
    }

    @Override
    public AppVersion update(Integer id, AppVersionRequest updateRequest) {
        checkUniqueVersion(updateRequest.version(), id);
        Optional<AppVersion> optional = appVersionRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        AppVersion old = optional.get();
        AppVersion updated = new AppVersion(
            old.id(),
            updateRequest.version(),
            updateRequest.minimalVersion(),
            updateRequest.expiryDate()
        );
        appVersionRepository.save(updated);
        return updated;
    }

    @Override
    public void delete(Integer id) {
        appVersionRepository.deleteById(id);
    }

    private boolean isBlockedVersion(AppVersion appVersion, SemanticVersion currentVersion) {
        return !appVersion.minimalVersion() && currentVersion.equals(new SemanticVersion(appVersion.version()));
    }

    private boolean isMinimalVersionGreater(AppVersion appVersion, SemanticVersion currentVersion) {
        return appVersion.minimalVersion() && currentVersion.isLowerThan(new SemanticVersion(appVersion.version()));
    }

    private void checkUniqueVersion(String version, Integer selfId) {
        if (appVersionRepository.existsByVersion(version, selfId)) {
            throw new ConflictException("Version already exists");
        }
    }
}
