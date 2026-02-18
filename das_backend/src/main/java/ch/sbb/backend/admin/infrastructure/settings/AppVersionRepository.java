package ch.sbb.backend.admin.infrastructure.settings;

import ch.sbb.backend.admin.infrastructure.settings.model.AppVersionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppVersionRepository extends JpaRepository<AppVersionEntity, Integer> {

}
