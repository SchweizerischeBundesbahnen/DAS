package ch.sbb.das.backend.appversions.internal;

import ch.sbb.das.backend.appversions.AppVersionService;
import ch.sbb.das.backend.appversions.CurrentAppVersion;
import ch.sbb.das.backend.common.ConflictException;
import ch.sbb.das.backend.common.DateTimeUtil;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class AppVersionServiceImpl implements AppVersionService {

    private final AppVersionRepository appVersionRepository;

    public AppVersionServiceImpl(AppVersionRepository appVersionRepository) {
        this.appVersionRepository = appVersionRepository;
    }

    @Override
    public CurrentAppVersion getCurrent(String appVersion) {
        if (appVersion == null) {
            return CurrentAppVersion.DEFAULT;
        }
        SemanticVersion currentVersion = new SemanticVersion(appVersion);

        List<AppVersionEntity> relevantVersions = appVersionRepository.findAll().stream().filter(entity -> isBlockedVersion(entity, currentVersion) || isMinimalVersionGreater(entity, currentVersion))
            .toList();

        boolean expired = relevantVersions.stream().anyMatch(relevantVersion -> this.isExpired(relevantVersion.getExpiryDate()));

        LocalDate expiryDate = relevantVersions.stream()
            .map(AppVersionEntity::getExpiryDate)
            .filter(Objects::nonNull)
            .filter(date -> !this.isExpired(date))
            .min(Comparator.naturalOrder())
            .orElse(null);

        return new CurrentAppVersion(expired, expiryDate);
    }

    List<AppVersion> getAll() {
        return appVersionRepository.findAll().stream().map(AppVersionEntity::toAppVersion).toList();
    }

    AppVersion getById(Integer id) {
        Optional<AppVersion> appVersion = appVersionRepository.findById(id).map(AppVersionEntity::toAppVersion);
        return appVersion.orElse(null);
    }

    AppVersion create(AppVersionRequest createRequest) {
        checkUniqueVersion(createRequest.version(), null);
        AppVersion appVersion = new AppVersion(null, createRequest.version(), createRequest.minimalVersion(), createRequest.expiryDate());
        return appVersionRepository.save(AppVersionEntity.from(appVersion)).toAppVersion();
    }

    AppVersion update(Integer id, AppVersionRequest updateRequest) {
        Optional<AppVersion> optional = appVersionRepository.findById(id).map(AppVersionEntity::toAppVersion);
        if (optional.isEmpty()) {
            return null;
        }
        checkUniqueVersion(updateRequest.version(), id);
        AppVersion old = optional.get();
        AppVersion updated = new AppVersion(old.id(), updateRequest.version(), updateRequest.minimalVersion(), updateRequest.expiryDate());
        return appVersionRepository.save(AppVersionEntity.from(updated)).toAppVersion();
    }

    void delete(Integer id) {
        appVersionRepository.deleteById(id);
    }

    private boolean isExpired(LocalDate expiryDate) {
        return expiryDate == null || !expiryDate.isAfter(DateTimeUtil.today());
    }

    private boolean isBlockedVersion(AppVersionEntity appVersion, SemanticVersion currentVersion) {
        return !appVersion.getMinimalVersion() && currentVersion.equals(new SemanticVersion(appVersion.getVersion()));
    }

    private boolean isMinimalVersionGreater(AppVersionEntity appVersion, SemanticVersion currentVersion) {
        return appVersion.getMinimalVersion() && currentVersion.isLowerThan(new SemanticVersion(appVersion.getVersion()));
    }

    private void checkUniqueVersion(String version, Integer selfId) {
        if (appVersionRepository.existsByVersionAndIdNot(version, selfId)) {
            throw new ConflictException("Version already exists");
        }
    }
}


