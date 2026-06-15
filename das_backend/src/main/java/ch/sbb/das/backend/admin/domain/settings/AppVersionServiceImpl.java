package ch.sbb.das.backend.admin.domain.settings;

import ch.sbb.das.backend.admin.application.settings.model.request.AppVersionRequest;
import ch.sbb.das.backend.admin.application.settings.model.response.AppVersion;
import ch.sbb.das.backend.admin.application.settings.model.response.CurrentAppVersion;
import ch.sbb.das.backend.admin.domain.settings.model.SemanticVersion;
import ch.sbb.das.backend.common.ConflictException;
import ch.sbb.das.backend.common.DateTimeUtil;
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

        List<AppVersion> relevantVersions = appVersionRepository.findAll().stream().filter(entity -> isBlockedVersion(entity, currentVersion) || isMinimalVersionGreater(entity, currentVersion))
            .toList();

        boolean expired = relevantVersions.stream().anyMatch(relevantVersion -> this.isExpired(relevantVersion.expiryDate()));

        LocalDate expiryDate = relevantVersions.stream()
            .map(AppVersion::expiryDate)
            .filter(Objects::nonNull)
            .filter(date -> !this.isExpired(date))
            .min(Comparator.naturalOrder())
            .orElse(null);

        return new CurrentAppVersion(expired, expiryDate);
    }

    private boolean isExpired(LocalDate expiryDate) {
        return expiryDate == null || !expiryDate.isAfter(DateTimeUtil.today());
    }

    @Override
    public AppVersion getById(Integer id) {
        Optional<AppVersion> entity = appVersionRepository.findById(id);
        return entity.orElse(null);
    }

    @Override
    public AppVersion create(AppVersionRequest createRequest) {
        checkUniqueVersion(createRequest.version(), null);
        AppVersion appVersion = new AppVersion(null, createRequest.version(), createRequest.minimalVersion(), createRequest.expiryDate());
        return appVersionRepository.save(appVersion);
    }

    @Override
    public AppVersion update(Integer id, AppVersionRequest updateRequest) {
        Optional<AppVersion> optional = appVersionRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        checkUniqueVersion(updateRequest.version(), id);
        AppVersion old = optional.get();
        AppVersion updated = new AppVersion(old.id(), updateRequest.version(), updateRequest.minimalVersion(), updateRequest.expiryDate());
        return appVersionRepository.save(updated);
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
