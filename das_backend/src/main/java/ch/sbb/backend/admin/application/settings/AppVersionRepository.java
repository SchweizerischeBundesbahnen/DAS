package ch.sbb.backend.admin.application.settings;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppVersionRepository extends JpaRepository<AppVersionEntity, Long> {

    List<AppVersionEntity> findAll();
}
