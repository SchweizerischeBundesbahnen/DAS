package ch.sbb.backend.admin.domain.settings;

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
        // todo make more readable

        //        exactly blockedVersion || minimalVersion greater
        List<AppVersionEntity> relevantVersions = repository.findAll().stream()
            .filter(entity ->
                // exactly blocked = minimalVersion false && version == currentVersion
                !entity.getMinimalVersion() && currentVersion.equals(new SemVersion(entity.getVersion())) ||
                    // minimalVersion = minimalVersion true && version greater than currentVersion
                    entity.getMinimalVersion() && currentVersion.isLowerThan(new SemVersion(entity.getVersion())))
            .toList();
        // expired = (expiry date null || expiry date in the past ) && exactly blockedVersion || minimalVersion greater
        boolean expired = relevantVersions.stream().anyMatch(entity -> entity.getExpiryDate() == null || entity.getExpiryDate().isBefore(LocalDate.now()));

        // expiryDate = expiry date in the future && ( version exactly blocked || minimalVersion greater)
        LocalDate expiryDate = relevantVersions.stream()
            .map(AppVersionEntity::getExpiryDate)
            .filter(Objects::nonNull)
            .filter(versionExpiryDate -> versionExpiryDate.isAfter(LocalDate.now()))
            .min(Comparator.comparing(versionExpiryDate -> versionExpiryDate)).orElse(null);

        return new CurrentAppVersion(expired, expiryDate);
    }
}
